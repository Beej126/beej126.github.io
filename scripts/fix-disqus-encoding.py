"""Repair malformed apostrophes in imported GitHub comments, preserving IDs."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import time
from disqus_text import repair_legacy_entities

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / '_migration' / 'disqus'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--publish', action='store_true')
    args = parser.parse_args()
    pages = json.loads(subprocess.check_output([
        'gh', 'api', 'repos/Beej126/beej126.github.io/issues/comments?per_page=100',
        '--paginate', '--slurp'], text=True, encoding='utf-8'))
    changes = []
    for comment in (c for page in pages for c in page):
        if '<!-- disqus-comment:' not in comment['body']:
            continue
        updated = repair_legacy_entities(comment['body'])
        if updated != comment['body']:
            changes.append({'id': comment['id'], 'url': comment['html_url'], 'before': comment['body'], 'after': updated})
    # Keep the first pre-edit backup intact across retries.
    backup = OUT / 'encoding-repairs.json'
    if not backup.exists():
        backup.write_text(json.dumps(changes, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(changes)} comments need repair.', flush=True)
    if not args.publish:
        return
    for index, change in enumerate(changes, 1):
        with tempfile.TemporaryDirectory(prefix='beej-comment-fix-') as directory:
            payload = Path(directory) / 'body.json'
            payload.write_text(json.dumps({'body': change['after']}, ensure_ascii=False), encoding='utf-8')
            result = json.loads(subprocess.check_output([
                'gh', 'api', f"repos/Beej126/beej126.github.io/issues/comments/{change['id']}",
                '--method', 'PATCH', '--input', str(payload)], text=True, encoding='utf-8'))
            assert result['body'] == change['after']
        time.sleep(1.1)
        if index % 10 == 0 or index == len(changes):
            print(f'Repaired {index}/{len(changes)} comments.', flush=True)
    for name in ('import-plan.json', 'deferred-comments.json'):
        path = OUT / name
        data = json.loads(path.read_text(encoding='utf-8'))
        entries = [c for post in data for c in post['comments']] if name == 'import-plan.json' else data
        for entry in entries:
            entry['body_html'] = repair_legacy_entities(entry['body_html'])
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
