"""Vendor the theme's pinned libraries and current Google Fonts responses."""
import base64
import hashlib
import json
from pathlib import Path
import re
from urllib.parse import urljoin, urlsplit
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / 'assets' / 'vendor'
MANIFEST = []
UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'


def download(url, relative, integrity=None):
    with urlopen(Request(url, headers={'User-Agent': UA}), timeout=30) as response:
        data = response.read()
        final_url = response.url
    if integrity:
        algorithm, expected = integrity.split('-', 1)
        actual = base64.b64encode(hashlib.new(algorithm, data).digest()).decode()
        if actual != expected: raise ValueError('Integrity mismatch: ' + url)
    path = DEST / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    MANIFEST.append({'source': url, 'resolved_source': final_url, 'file': relative, 'download_sha256': hashlib.sha256(data).hexdigest()})
    return data


def stylesheet(url, relative):
    text = download(url, relative).decode('utf-8')
    def replace(match):
        raw = match[1].strip('"\' ')
        if raw.startswith('data:'): return match[0]
        source = urljoin(url, raw)
        suffix = Path(urlsplit(source).path).suffix
        name = 'fonts/' + hashlib.sha256(source.encode()).hexdigest()[:16] + suffix
        target = (Path(relative).parent / name).as_posix()
        if not any(item['file'] == target for item in MANIFEST): download(source, target)
        fragment = urlsplit(source).fragment
        return 'url("' + name + ('#' + fragment if fragment else '') + '")'
    text = re.sub(r'url\(([^)]+)\)', replace, text)
    (DEST / relative).write_text(text, encoding='utf-8')


def main():
    download('https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css', 'bootstrap/bootstrap.min.css', 'sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh')
    download('https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css.map', 'bootstrap/bootstrap.min.css.map')
    download('https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js', 'bootstrap/bootstrap.min.js', 'sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6')
    download('https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js.map', 'bootstrap/bootstrap.min.js.map')
    download('https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js', 'jquery/jquery.slim.min.js', 'sha256-4+XzXVhsDmqanXGHaHvgh1gMQKX40OUvDEBTu8JcmNs=')
    download('https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js', 'popper/popper.min.js', 'sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo')
    download('https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js.map', 'popper/popper.min.js.map')
    stylesheet('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css', 'font-awesome/all.min.css')
    stylesheet('https://fonts.googleapis.com/css?family=Lora:400,700,400italic,700italic&display=swap', 'google-fonts/lora.css')
    stylesheet('https://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800&display=swap', 'google-fonts/open-sans.css')
    metadata = json.loads(download('https://unpkg.com/simple-jekyll-search@latest/package.json', 'simple-jekyll-search/package.json'))
    version = metadata['version']
    download(f'https://unpkg.com/simple-jekyll-search@{version}/dest/simple-jekyll-search.min.js', 'simple-jekyll-search/simple-jekyll-search.min.js')
    licenses = {
        'bootstrap/LICENSE': 'https://raw.githubusercontent.com/twbs/bootstrap/v4.4.1/LICENSE',
        'jquery/LICENSE.txt': 'https://raw.githubusercontent.com/jquery/jquery/3.5.1/LICENSE.txt',
        'popper/LICENSE.md': 'https://raw.githubusercontent.com/popperjs/popper-core/v1.16.0/LICENSE.md',
        'font-awesome/LICENSE.txt': 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/5.12.1/LICENSE.txt',
        'google-fonts/Lora-OFL.txt': 'https://raw.githubusercontent.com/google/fonts/main/ofl/lora/OFL.txt',
        'google-fonts/OpenSans-OFL.txt': 'https://raw.githubusercontent.com/google/fonts/main/ofl/opensans/OFL.txt',
        'simple-jekyll-search/LICENSE.md': f'https://unpkg.com/simple-jekyll-search@{version}/LICENSE.md',
    }
    for file, url in licenses.items(): download(url, file)
    for item in MANIFEST:
        item['local_sha256'] = hashlib.sha256((DEST / item['file']).read_bytes()).hexdigest()
    (DEST / 'manifest.json').write_text(json.dumps(MANIFEST, indent=2) + '\n', encoding='utf-8')
    print(f'Vendored {len(MANIFEST)} files, search version {version}; font CSS URLs rewritten locally.')


if __name__ == '__main__':
    main()
