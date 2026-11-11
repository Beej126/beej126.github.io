"""Match a Disqus XML export to current and archived Markdown posts without editing them."""
import argparse
import collections
import html
import json
from pathlib import Path
import re
import subprocess
import unicodedata
from urllib.parse import unquote, urlsplit, parse_qs
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
NS = {"d": "http://disqus.com"}
ID = "{http://disqus.com/disqus-internals}id"


def normalize(value):
    value = re.sub(r"\s*[~|]\s*/.*?BeejBlog.*$", "", value, flags=re.I)
    return re.sub(r"[^\w]+", "", unicodedata.normalize("NFKC", html.unescape(value)).casefold())


def urlkey(value):
    wrapped = parse_qs(urlsplit(value).query).get("u", [])
    if wrapped and wrapped[0].startswith(("http://", "https://")):
        value = wrapped[0]
    return unquote(urlsplit(value).path).replace("__trashed", "").rstrip("/").casefold()


def metadata(text):
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    fm = parts[1]
    title = re.search(r"^title:\s*(.+)$", fm, re.M)
    return {
        "title": title[1].strip().strip("\"'") if title else "",
        "ids": re.findall(r"^dsq_thread_id:\s*\n\s*-\s*['\"]?(\d+)", fm, re.M),
        "urls": re.findall(r"^(?:url|blogger_permalink):\s*(?:\n\s*-\s*)?([^\s]+)", fm, re.M),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("export", type=Path)
    parser.add_argument("--output", type=Path, default=ROOT / "_migration" / "disqus")
    args = parser.parse_args()
    records = {}
    for folder in ("_posts", "_boring_posts"):
        for path in sorted((ROOT / folder).glob("*.md")):
            relative = path.relative_to(ROOT).as_posix()
            records[relative] = metadata(path.read_text(encoding="utf-8-sig"))
    indexes = {key: collections.defaultdict(set) for key in ("id", "url", "title", "slug")}

    def index(path, data):
        for thread_id in data.get("ids", []):
            indexes["id"][thread_id].add(path)
        for url in data.get("urls", []):
            indexes["url"][urlkey(url.strip("\"'"))].add(path)
        if data.get("title"):
            indexes["title"][normalize(data["title"])].add(path)

    for path, data in records.items():
        index(path, data)
        indexes["slug"][normalize(Path(path).stem[11:])].add(path)

    # Recover deleted metadata from every historical version of the post folders.
    # Resolve historical paths to current files by filename, including moved posts.
    by_name = collections.defaultdict(set)
    for path in records:
        by_name[Path(path).name].add(path)
    history = subprocess.check_output(
        ["git", "log", "--all", "--format=", "-p", "--", "_posts", "_boring_posts"], cwd=ROOT
    ).decode("utf-8", errors="replace")
    for patch in re.split(r"(?m)^diff --git ", history)[1:]:
        header, _, body = patch.partition("\n")
        name = header.split(" b/", 1)[-1].strip('"')
        candidates = by_name.get(Path(name).name, set())
        if not candidates:
            continue
        # Read each diff side independently; YAML fields can appear in deletions.
        for marker in ("-", "+"):
            side = "\n".join(line[1:] for line in body.splitlines()
                             if line.startswith((marker, " ")) and not line.startswith(("--- ", "+++ ")))
            for candidate in candidates:
                for thread_id in re.findall(r"dsq_thread_id:\s*\n\s*-\s*['\"]?(\d+)", side):
                    indexes["id"][thread_id].add(candidate)
                for url in re.findall(r"(?:^|\n)(?:url|blogger_permalink):\s*(?:\n\s*-\s*)?([^\s]+)", side):
                    indexes["url"][urlkey(url.strip("\"'"))].add(candidate)

    root = ET.parse(args.export).getroot()
    comments = collections.defaultdict(list)
    for post in root.findall("d:post", NS):
        thread = post.find("d:thread", NS)
        parent = post.find("d:parent", NS)
        comments[thread.get(ID) if thread is not None else None].append({
            "comment_id": post.get(ID),
            "parent_id": parent.get(ID) if parent is not None else None,
            "created_at": post.findtext("d:createdAt", namespaces=NS),
            "deleted": post.findtext("d:isDeleted", namespaces=NS) == "true",
            "spam": post.findtext("d:isSpam", namespaces=NS) == "true",
        })
    matched = []
    for thread in root.findall("d:thread", NS):
        thread_id = thread.get(ID)
        title = thread.findtext("d:title", default="", namespaces=NS)
        link = thread.findtext("d:link", default="", namespaces=NS)
        identifier = thread.findtext("d:id", default="", namespaces=NS)
        candidates = set()
        method = None
        for key, values in (
            ("id", [thread_id]),
            ("url", [urlkey(link)] + [urlkey(u) for u in re.findall(r"https?://\S+", identifier)]),
            ("title", [normalize(title)]),
            ("slug", [normalize(Path(urlsplit(link).path).stem)]),
        ):
            candidates = set().union(*(indexes[key].get(value, set()) for value in values if value))
            if candidates:
                method = key
                break
        matched.append({"thread_id": thread_id, "title": title, "original_url": link,
                        "post": next(iter(candidates)) if len(candidates) == 1 else None,
                        "method": method, "candidates": sorted(candidates),
                        "comments": comments.pop(thread_id, [])})
    # Other exported threads can refer to the same article under old branding,
    # domains or previews. Reuse only unambiguous aliases from resolved records.
    aliases = collections.defaultdict(set)
    for item in matched:
        if item["post"]:
            aliases[normalize(item["title"])].add(item["post"])
    for item in matched:
        if item["post"]:
            continue
        candidates = aliases.get(normalize(item["title"]), set())
        if len(candidates) == 1:
            item.update(post=next(iter(candidates)), method="export-title-alias", candidates=sorted(candidates))
    grouped = collections.defaultdict(lambda: {"thread_ids": [], "comment_ids": []})
    for item in matched:
        if item["post"]:
            grouped[item["post"]]["thread_ids"].append(item["thread_id"])
            grouped[item["post"]]["comment_ids"].extend(c["comment_id"] for c in item["comments"])
    output = args.output
    output.mkdir(parents=True, exist_ok=True)
    result = {"threads": matched, "posts": dict(sorted(grouped.items())), "comments_without_exported_thread": dict(comments)}
    (output / "matches.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    counts = collections.Counter("matched" if item["post"] else "ambiguous" if item["candidates"] else "unmatched" for item in matched)
    lines = ["# Disqus post matching", "", f"Threads: {len(matched)}. Results: {dict(counts)}.", "",
             "Matches by Disqus ID or URL are strongest. Title and slug matches should be reviewed before importing.",
             "Comment IDs, reply relationships and moderation flags are in matches.json; comment bodies and personal data remain in the original export.", "",
             "| Thread ID | Comments | Match | Markdown post / candidates | Title |", "|---|---:|---|---|---|"]
    for item in matched:
        target = item["post"] or ", ".join(item["candidates"]) or "**UNMATCHED**"
        lines.append(f"| {item['thread_id']} | {len(item['comments'])} | {item['method'] or 'none'} | {target} | {item['title'].replace('|', '&#124;')} |")
    (output / "REPORT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    post_lines = ["# Comments grouped by Markdown post", "", "Multiple old Disqus threads may belong to one post. No comments have been published or post files modified.", "",
                  "| Markdown post | Threads | Comments |", "|---|---:|---:|"]
    for path, group in sorted(grouped.items()):
        post_lines.append(f"| {path} | {len(group['thread_ids'])} | {len(group['comment_ids'])} |")
    (output / "BY_POST.md").write_text("\n".join(post_lines) + "\n", encoding="utf-8")
    print(json.dumps({"threads": len(matched), "results": dict(counts), "comments": sum(len(t['comments']) for t in matched), "orphan_comments": sum(map(len, comments.values()))}))
    for item in matched:
        if not item["post"]:
            print("REVIEW", json.dumps({"id": item["thread_id"], "title": item["title"], "url": item["original_url"], "candidates": item["candidates"]}))


if __name__ == "__main__":
    main()
