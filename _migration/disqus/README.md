# Disqus to Utterances migration

Only eligible comments belonging to active `_posts` are published. Spam and
deleted comments are excluded. GitHub records the importing account and import
time; original display names and timestamps are included in comment bodies.
Reply relationships link to imported parent comments when available. Export
email addresses, IP addresses, and account credentials are not imported.

- `matches.json`, `REPORT.md`, `BY_POST.md`: export-to-Markdown mapping, including
  archived posts and empty threads.
- `import-plan.json`: 184 eligible active-post comments grouped under 24 posts.
- `deferred-comments.json`: 21 eligible comments for 10 `_boring_posts`, with
  original bodies, authors, dates, thread IDs, and reply IDs for later recovery.
- `excluded-comments.json`: IDs and moderation flags for 16 spam/deleted comments;
  their bodies are not retained here.
- `imported.json`: resumable record of GitHub issue and comment URLs.
- `../../_data/utterances.json`: active post paths mapped to GitHub issue numbers.

The Utterances template uses mapped issue numbers for migrated posts and retains
the configured title matching for other posts. These local migration files are
not included in the generated website. No archived-post issues are created.

The importer can be resumed without duplicating comments. It reads existing
GitHub issues and per-comment migration markers before writing. Preparing a plan
requires a local Jekyll build in `_site`; GitHub CLI authentication is required
only for publishing:

```powershell
python scripts/import-disqus.py <path-to-export>
python scripts/import-disqus.py <path-to-export> --publish
```

Publishing is a separate operation from pushing the blog repository. The local
template and issue mapping must be deployed before the live blog uses the
explicit mappings.
