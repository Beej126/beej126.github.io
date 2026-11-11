# Self-hosted theme dependencies

These files are committed static assets. Normal builds do not download libraries
or fonts from CDNs. Versions match the theme's previous dependencies:

| Dependency | Version |
|---|---|
| Bootstrap | 4.4.1 |
| jQuery slim | 3.5.1 |
| Popper.js | 1.16.0 |
| Font Awesome Free | 5.12.1 |
| Simple Jekyll Search | 1.10.0 |
| Lora and Open Sans | Google Fonts response captured in manifest |

`manifest.json` records original/resolved download URLs and SHA-256 hashes for
downloaded and local files. Font stylesheet URLs were rewritten to local font
files, preserving all supplied language subsets and requested weights/styles.
Upstream license files are included in each dependency directory. Source maps
for Bootstrap and Popper are included for local developer tools.

`python scripts/vendor-assets.py` refreshes these assets explicitly. It verifies
the theme's original integrity hashes for the pinned core files. Review changes
before committing: Google Fonts responses and the search package's `latest`
release may change when the script is deliberately rerun. Normal builds use the
committed files, including the pinned search script, without consulting `latest`.

Utterances and configured Google Analytics remain external services. Remote
README/Gist content and comment-count refreshes still access their sources at
build time with saved fallbacks. They are separate from these theme assets.
