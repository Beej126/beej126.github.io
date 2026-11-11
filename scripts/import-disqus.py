"""Prepare/import active-post Disqus comments into GitHub Issues for Utterances."""
import argparse
import html
import json
from pathlib import Path
import re
import subprocess
import tempfile
import time
import xml.etree.ElementTree as ET
from disqus_text import repair_legacy_entities

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / '_migration' / 'disqus'
REPO = 'Beej126/beej126.github.io'
NS = {'d': 'http://disqus.com'}
ID = '{http://disqus.com/disqus-internals}id'


def api(endpoint, payload=None):
    command = ['gh', 'api', endpoint]
    if payload is None:
        return json.loads(subprocess.check_output(command, text=True, encoding='utf-8'))
    with tempfile.TemporaryDirectory(prefix='beej-disqus-') as directory:
        path = Path(directory) / 'payload.json'
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding='utf-8')
        result = json.loads(subprocess.check_output(command + ['--method', 'POST', '--input', str(path)], text=True, encoding='utf-8'))
    time.sleep(1.1)
    return result


def pages(endpoint):
    result = subprocess.check_output(['gh', 'api', endpoint, '--paginate', '--slurp'], text=True, encoding='utf-8')
    return [item for page in json.loads(result) for item in page]


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('export', type=Path)
    parser.add_argument('--publish', action='store_true')
    args = parser.parse_args()
    matches = json.loads((OUT / 'matches.json').read_text(encoding='utf-8'))
    thread_posts = {t['thread_id']: t['post'] for t in matches['threads'] if t['post']}
    grouped = {}
    deferred = []
    excluded = []
    for comment in ET.parse(args.export).getroot().findall('d:post', NS):
        thread = comment.find('d:thread', NS)
        thread_id = thread.get(ID)
        post = thread_posts.get(thread_id)
        if not post:
            raise ValueError('Unmapped comment: ' + str(comment.get(ID)))
        parent = comment.find('d:parent', NS)
        record = {
            'comment_id': comment.get(ID), 'thread_id': thread_id, 'post': post,
            'parent_id': parent.get(ID) if parent is not None else None,
            'author': comment.findtext('d:author/d:name', default='Anonymous', namespaces=NS),
            'created_at': comment.findtext('d:createdAt', namespaces=NS),
            'body_html': repair_legacy_entities(comment.findtext('d:message', default='', namespaces=NS)),
            'deleted': comment.findtext('d:isDeleted', namespaces=NS) == 'true',
            'spam': comment.findtext('d:isSpam', namespaces=NS) == 'true',
        }
        if record['deleted'] or record['spam']:
            # Preserve IDs/flags, not unpublished comment bodies or personal data.
            excluded.append({k: record[k] for k in ('comment_id', 'thread_id', 'post', 'deleted', 'spam')})
        elif post.startswith('_boring_posts/'):
            deferred.append(record)
        else:
            grouped.setdefault(post, []).append(record)
    plan = []
    for post, comments in sorted(grouped.items()):
        slug = Path(post).stem[11:]
        rendered = ROOT / '_site' / slug / 'index.html'
        page = rendered.read_text(encoding='utf-8')
        title = html.unescape(re.search(r'<title>(.*?)</title>', page, re.S)[1]).strip()
        canonical = 'https://Next-Technologies.com/' + slug + '/'
        plan.append({'post': post, 'title': title, 'url': canonical,
                     'comments': sorted(comments, key=lambda c: (c['created_at'], int(c['comment_id'])))})
    save(OUT / 'import-plan.json', plan)
    save(OUT / 'deferred-comments.json', deferred)
    save(OUT / 'excluded-comments.json', excluded)
    print(f"Prepared {sum(len(p['comments']) for p in plan)} comments across {len(plan)} active posts; {len(deferred)} deferred; {len(excluded)} excluded.", flush=True)
    if not args.publish:
        return

    endpoint = f'repos/{REPO}'
    issues = [i for i in pages(endpoint + '/issues?state=all&per_page=100') if 'pull_request' not in i]
    labels = api(endpoint + '/labels?per_page=100')
    if not any(label['name'] == 'blog-comments' for label in labels):
        api(endpoint + '/labels', {'name': 'blog-comments', 'color': 'c5def5', 'description': 'Blog discussions via Utterances'})
    mapping_path = ROOT / '_data' / 'utterances.json'
    mapping = json.loads(mapping_path.read_text(encoding='utf-8')) if mapping_path.exists() else {}
    state_path = OUT / 'imported.json'
    state = json.loads(state_path.read_text(encoding='utf-8')) if state_path.exists() else {'posts': {}, 'comments': {}}
    created = 0
    for entry in plan:
        marker = '<!-- disqus-post:' + entry['post'] + ' -->'
        candidates = [i for i in issues if marker in (i.get('body') or '') or i['title'] == entry['title']]
        if len(candidates) > 1:
            raise ValueError('Multiple matching issues for ' + entry['post'])
        if candidates:
            issue = candidates[0]
            if issue.get('locked'):
                raise ValueError('Matching issue is locked: ' + str(issue['number']))
            if not any(label['name'] == 'blog-comments' for label in issue['labels']):
                api(endpoint + f"/issues/{issue['number']}/labels", {'labels': ['blog-comments']})
        else:
            body = f"# {entry['title']}\n\n[{entry['url']}]({entry['url']})\n\nComments for this blog post. Earlier comments were imported from Disqus; original authors and dates are recorded in each imported comment.\n\n{marker}"
            issue = api(endpoint + '/issues', {'title': entry['title'], 'body': body, 'labels': ['blog-comments']})
            issues.append(issue)
        number = issue['number']
        mapping[entry['post']] = number
        state['posts'][entry['post']] = {'issue': number, 'url': issue['html_url']}
        save(mapping_path, dict(sorted(mapping.items())))
        save(state_path, state)
        existing = pages(endpoint + f'/issues/{number}/comments?per_page=100')
        imported = {}
        for item in existing:
            match = re.search(r'<!-- disqus-comment:(\d+) -->', item['body'])
            if match:
                imported[match[1]] = item['html_url']
        for comment in entry['comments']:
            comment_id = comment['comment_id']
            if comment_id in imported:
                state['comments'][comment_id] = imported[comment_id]
                continue
            author = html.escape(comment['author']).replace('@', '&#64;')
            date = comment['created_at']
            attribution = f"<strong>Originally posted by {author} on {date}</strong>"
            reply = ''
            if comment['parent_id']:
                parent_url = imported.get(comment['parent_id']) or state['comments'].get(comment['parent_id'])
                reply = f"\n\nReply to [an earlier comment]({parent_url})." if parent_url else f"\n\nReply to original Disqus comment `{comment['parent_id']}`."
            # Avoid notifying GitHub users from old @mentions; omit export emails/IPs.
            content = comment['body_html'].replace('@', '&#64;')
            body = f"{attribution}{reply}\n\n{content}\n\n<!-- disqus-comment:{comment_id} -->"
            result = api(endpoint + f'/issues/{number}/comments', {'body': body})
            imported[comment_id] = result['html_url']
            state['comments'][comment_id] = result['html_url']
            created += 1
            save(state_path, state)
        print(f"Issue #{number}: {entry['post']} ({len(entry['comments'])} comments reconciled; {created} new comments this run)", flush=True)
    save(state_path, state)
    print(f"Complete: {len(plan)} active posts mapped, {created} comments created.", flush=True)


if __name__ == '__main__':
    main()
