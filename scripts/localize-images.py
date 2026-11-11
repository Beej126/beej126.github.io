"""Download article images, recover failures from Wayback, and rewrite local posts."""
import argparse
import concurrent.futures
import hashlib
from html import escape, unescape
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import threading
from urllib.parse import urlsplit, unquote, urlencode
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / '_migration' / 'images'
HEADERS = {'User-Agent': 'BeejBlog-image-preservation/1.0'}


def image_extension(data):
    if data.startswith(b'\x89PNG\r\n\x1a\n'): return '.png'
    if data.startswith(b'\xff\xd8\xff'): return '.jpg'
    if data.startswith((b'GIF87a', b'GIF89a')): return '.gif'
    if data[:4] == b'RIFF' and data[8:12] == b'WEBP': return '.webp'
    if data[:2] == b'BM': return '.bmp'
    if b'<svg' in data[:1000].lower(): return '.svg'
    if len(data) > 12 and data[4:8] == b'ftyp' and data[8:12] in (b'avif', b'avis'): return '.avif'
    raise ValueError('Response is not a recognized image')


def fetch(url):
    with urlopen(Request(url, headers=HEADERS), timeout=20) as response:
        data = response.read(30 * 1024 * 1024 + 1)
    if len(data) > 30 * 1024 * 1024: raise ValueError('Image exceeds 30 MB')
    return data, image_extension(data)


class Images(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.urls = set()

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        values = []
        if tag == 'img':
            values.append(attrs.get('src', ''))
            if attrs.get('srcset'):
                values += [part.strip().split()[0] for part in attrs['srcset'].split(',') if part.strip()]
        if tag == 'a' and re.search(r'\.(?:png|jpe?g|gif|webp|svg|bmp)(?:[?#]|$)', attrs.get('href', ''), re.I):
            values.append(attrs['href'])
        for value in values:
            if value.startswith(('https://', 'http://', '//')): self.urls.add(value)
            elif value.startswith('/images/uploads/') and not (ROOT / unquote(value).lstrip('/')).is_file():
                self.urls.add(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--placeholder-missing', action='store_true', help='Use labeled local placeholders after recovery attempts fail')
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    registry_path = ROOT / '_data' / 'local_images.json'
    registry = json.loads(registry_path.read_text(encoding='utf-8')) if registry_path.exists() else {}
    prior_registry = dict(registry)
    old_results = json.loads((OUT / 'results.json').read_text(encoding='utf-8')) if (OUT / 'results.json').exists() else []
    previous = {item['url']: item for item in old_results}
    jobs = {}
    for post in sorted((ROOT / '_posts').glob('*.md')):
        page = ROOT / '_site' / post.stem[11:] / 'index.html'
        if not page.exists(): continue
        images = Images()
        images.feed(page.read_text(encoding='utf-8'))
        for url in images.urls:
            jobs.setdefault(url, []).append(post.relative_to(ROOT).as_posix())
    # Preserve the inventory across reruns after sources become local.
    for item in old_results:
        jobs.setdefault(item['url'], item['posts'])
    hashes = {}
    for path in (ROOT / 'images' / 'uploads').rglob('*'):
        if path.is_file():
            hashes.setdefault(hashlib.sha256(path.read_bytes()).hexdigest(), '/' + path.relative_to(ROOT).as_posix())
    lock = threading.Lock()

    def process(job):
        url, posts = job
        result = {'url': url, 'posts': posts}
        if url in registry and '/unavailable-' in registry[url] and not args.archive:
            return dict(previous.get(url, result), local=registry[url], method='unavailable-placeholder', unresolved=True)
        if url in registry and '/unavailable-' not in registry[url] and (ROOT / registry[url].lstrip('/')).is_file():
            return previous.get(url, dict(result, local=registry[url], method='already-local'))
        if url.startswith('//images/'):
            local = url[1:]
            if (ROOT / local.lstrip('/')).is_file(): return dict(result, local=local, method='repaired-local-path')
            return dict(result, direct_error='Missing local screenshot (original post already notes the screenshots were lost)', archive_errors=[])
        source = 'https:' + url if url.startswith('//') else url
        if url.startswith('/images/uploads/'):
            source = 'https://www.beejblog.com/wp-content/uploads/' + url.removeprefix('/images/uploads/')
        try:
            data, ext = fetch(source)
            result['method'] = 'downloaded'
        except Exception as error:
            result['direct_error'] = str(error)
            # Original Google image links sometimes point at the former album UI.
            try:
                variant = source.replace('/s1600-h/', '/s1600/')
                if 'ggpht.com/' in variant: variant = variant.replace('*', '-').replace('/s1600-h/', '/s1600/')
                if variant == source: raise ValueError('No direct image variant')
                data, ext = fetch(variant)
                result['method'] = 'downloaded-fullsize-variant'
            except Exception:
                if not args.archive: return result
                errors = []
                variants = list(dict.fromkeys([source, source.replace('https://', 'http://', 1), source.split('?')[0], source.replace('://www.', '://')]))
                for variant in variants:
                    try:
                        endpoint = 'https://archive.org/wayback/available?' + urlencode({'url': variant})
                        with urlopen(Request(endpoint, headers=HEADERS), timeout=25) as response:
                            snapshot = json.load(response).get('archived_snapshots', {}).get('closest', {})
                        if not snapshot.get('available'): continue
                        archived = 'https://web.archive.org/web/' + snapshot['timestamp'] + 'id_/' + variant
                        data, ext = fetch(archived)
                        result.update(method='internet-archive', archive_url=archived)
                        break
                    except Exception as archive_error: errors.append(str(archive_error))
                else:
                    result['archive_errors'] = errors
                    return result
        digest = hashlib.sha256(data).hexdigest()
        with lock:
            if digest in hashes:
                result['local'] = hashes[digest]
                result['deduplicated'] = True
            else:
                post = Path(posts[0])
                path = ROOT / 'images' / 'uploads' / post.name[:4] / (post.stem[11:] + '-' + hashlib.sha256(url.encode()).hexdigest()[:12] + ext)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(data)
                result['local'] = '/' + path.relative_to(ROOT).as_posix()
                hashes[digest] = result['local']
        result.update(sha256=digest, bytes=len(data))
        return result

    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for result in pool.map(process, sorted(jobs.items())):
            results.append(result)
            if 'local' in result: registry[result['url']] = result['local']
            if len(results) % 25 == 0: print(f"Processed {len(results)}/{len(jobs)}; {sum('local' in r for r in results)} localized", flush=True)
            (OUT / 'results.json').write_text(json.dumps(results + [item for item in old_results if item['url'] not in {r['url'] for r in results}], indent=2) + '\n', encoding='utf-8')
    unresolved = [r for r in results if 'local' not in r or r.get('unresolved')]
    if args.placeholder_missing:
        svg = '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="180" viewBox="0 0 600 180"><rect width="600" height="180" rx="8" fill="#f6f8fa"/><text x="300" y="80" text-anchor="middle" font-family="sans-serif" font-size="22" fill="#57606a">Image unavailable</text><text x="300" y="115" text-anchor="middle" font-family="sans-serif" font-size="15" fill="#6e7781">The original image could not be recovered.</text></svg>\n'
        for item in unresolved:
            year = Path(item['posts'][0]).name[:4]
            local = '/images/uploads/' + year + '/unavailable-' + hashlib.sha256(item['url'].encode()).hexdigest()[:12] + '.svg'
            path = ROOT / local.lstrip('/')
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(svg, encoding='utf-8')
            item.update(local=local, method='unavailable-placeholder', unresolved=True)
            registry[item['url']] = local
    registry_path.write_text(json.dumps(dict(sorted(registry.items())), indent=2) + '\n', encoding='utf-8')
    (OUT / 'results.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
    if args.apply:
        for path in (ROOT / '_posts').glob('*.md'):
            raw = path.read_bytes()
            text = raw.decode('utf-8')
            for url in sorted(registry, key=len, reverse=True):
                # Replace exact source spellings, including entity-escaped HTML URLs.
                for spelling in {url, escape(url, quote=False)}:
                    text = text.replace(spelling, registry[url])
                if url in prior_registry and prior_registry[url] != registry[url]:
                    text = text.replace(prior_registry[url], registry[url])
                if url.startswith('//images/'):
                    text = re.sub(r'/\{\{\s*site\.baseurl\s*\}\}' + re.escape(url[1:]), '{{ site.baseurl }}' + registry[url], text)
            if text.encode('utf-8') != raw: path.write_bytes(text.encode('utf-8'))
    report = ['# Image localization', '', f'{len(results) - len(unresolved)} of {len(results)} source URLs localized; {len(unresolved)} unresolved.', '', '## Unresolved', '']
    for item in unresolved:
        report += [f"- {item['url']}", '  - Posts: ' + ', '.join(item['posts']), '  - Error: ' + item.get('direct_error', 'Unknown')]
    (OUT / 'REPORT.md').write_text('\n'.join(report) + '\n', encoding='utf-8')
    print(f"Localized {len(results) - len(unresolved)}/{len(results)} images. Unresolved: {len(unresolved)}", flush=True)


if __name__ == '__main__':
    main()
