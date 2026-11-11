# Static remote content

The **By Comments** navbar page ranks active posts using GitHub issue comment
counts fetched on each build. Explicit Utterances mappings take precedence;
other posts are matched using the configured page-title convention. Posts with
zero comments and pull requests are excluded. Ties show newer posts first.
Counts use the same saved-response fallback as remote embeds. New comments are
reflected on the next build; the published ranking requires no JavaScript.

Embed a remote Markdown file anywhere in a post:

```liquid
{% remote_markdown "https://raw.githubusercontent.com/Beej126/WeatherDesk/master/README.md" %}
```

Embed every file in a GitHub Gist, or select one filename:

```liquid
{% remote_gist "3064e77ddb5fad34ff04ee40ffec16bc" %}
{% remote_gist "3064e77ddb5fad34ff04ee40ffec16bc" "AutoUnZip.wsh.js" %}
```

Multiple tags can appear in one post. URLs and filenames must be quoted literals.
Markdown is rendered to HTML; Gist source files receive syntax highlighting, and
binary attachments receive download links. Relative links and media paths are
resolved against the source file. Each Gist filename has a small **source gist**
link beside it, followed by the wrap and copy buttons for code files. The controls
share the filename row and wrap naturally on narrow screens.
Source links open the specific file on GitHub in a shared window/tab named
`BeejBlogGistSource`. Subsequent ordinary clicks reuse and focus that window,
leaving the blog in place. Browser preferences determine whether it is a tab or
separate window; modified clicks retain their usual browser behavior.
Code is highlighted at build time with Rouge, detecting the language from each
filename and its contents. Colors use Rouge's GitHub theme in
`assets/css/pygment_highlights.css`; code-block layout is styled in
`assets/css/beautifuljekyll.css`.
Gist code blocks include a line-number gutter, starting at 1 for each file. The
numbers are generated with CSS so copying code preserves the original source.
Click a Gist line number to copy its URL, with brief **Link copied** feedback
beside the number. Copying does not scroll or change the address bar. Opening
the shared URL scrolls to and highlights that line. Links identify the Gist, filename,
and line number. If the remote source changes, that line number may refer to
different code. Repeated embeds receive distinct anchors.
With JavaScript enabled, code blocks also have a **Copy** button and brief
confirmation. If clipboard access is blocked, the button selects the code for
manual copying instead. These controls also apply to ordinary highlighted code
blocks in posts.
Code wraps by default. Use **No wrap** for horizontal scrolling, or **Wrap lines**
to restore wrapping. Gist line numbers stay aligned with wrapped source
lines. Wrapping changes only the display, preserving the copied source text.
Code blocks show at most 15 visual lines (plus padding), with internal scrolling
for longer files. Line-number gutters never wrap. Copy still includes the entire
file, including code outside the visible area.
For raw GitHub documents, document links open GitHub's file view. Article images
and image links are rewritten to local copies using `_data/local_images.json`.
New upstream images are downloaded during the build and included in static
output. Failed new downloads display a local unavailable-image placeholder and
log a warning; the next build retries. Liquid inside imported content is not executed.

To localize existing post images and attempt Internet Archive recovery:

```powershell
python scripts/localize-images.py --archive --apply --placeholder-missing
```

This scans a local build, deduplicates images by content, and writes recovered
assets under `images/uploads/YYYY`. `_migration/images/REPORT.md` lists missing
images; `results.json` records source URLs, local paths, and archive provenance.
Unrecoverable images receive labeled local placeholders. Running the archive
pass again retries those sources. Commit downloaded files and the image mapping
alongside the posts. Theme fonts, CSS and scripts are also self-hosted under
`assets/vendor` with licenses and checksums. Utterances, configured analytics,
and remote text/comment-count refreshes still use their respective services.

Every build fetches fresh content, with duplicate URLs fetched once per build.
GitHub Actions runs on pushes to `main` and through **Run workflow**; there is no
schedule. Remote repository edits alone do not trigger a blog build.

Successful downloads update `_remote_content/<SHA256-of-URL>.json`. These saved
responses are excluded from the generated site and file watcher. Commit them
when adding a new embed or refreshing its fallback.
Workflow builds update their working copy without creating commits. A fetch
failure uses the saved response and logs a warning; without a saved response it
fails the build, preserving the previous deployment. Snapshots are fallback
content, never a reason to skip trying the remote source.

## Local builds

From PowerShell, run this from the repository root:

```powershell
.\scripts\preview.ps1
```

Open <http://localhost:4100>. The script builds the site, serves it locally, and
automatically rebuilds when files change. Refresh the browser after a rebuild.
Stop it with Ctrl+C. Restart after changing `_config.yml` or plugin Ruby files.
Nothing is pushed or deployed.

The script uses native Ruby/Bundler when available, otherwise a Ruby 3.3 Podman
container. On this Windows machine it uses the existing `podman-machine-default`
WSL VM directly. The first container run installs gems into a reusable Podman
volume; subsequent runs reuse them. For another port or a build without serving:

```powershell
.\scripts\preview.ps1 -Port 4101
.\scripts\preview.ps1 -BuildOnly
# Explicitly choose a runtime if needed:
.\scripts\preview.ps1 -Runtime Podman
```

Use Ruby 3.3 and Bundler:

```sh
bundle install
bundle exec ruby tests/remote_content_test.rb
bundle exec jekyll build
# Or preview, fetching again whenever Jekyll rebuilds:
bundle exec jekyll serve
```

The tags live in `_plugins/remote_content.rb` and require a regular Jekyll build
with plugins enabled. The restricted `actions/jekyll-build-pages` builder cannot
load them. The workflow uses `ruby/setup-ruby` and `bundle exec jekyll build`,
followed by GitHub's Pages artifact upload and deployment actions. `Gemfile.lock`
records dependencies for repeatable builds. `GITHUB_TOKEN` is optional locally;
the workflow supplies it for authenticated GitHub Gist API requests.
