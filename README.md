# The `changelog` LaTeX package

[Available on CTAN as `changelog`][changelog]

Changelogs are important. Unfortunately, there are few facilities
for typesetting changelogs in LaTeX. `changelog` defines a `changelog`
environment to make changelogs simple and intuitive.

Inspired by [keepachangelog.com].

File                         | Description
-----------------------------|-------------------------------
changelog.sty                | The changelog package
changelog.pdf                | Documentation (English)
changelog.tex                | Documentation source
example.tex                  | Example use
example.pdf                  | Example use (PDF)
screenshot.png               | Sample screenshot
README.md                    | This file
LICENSE.txt                  | LPPL v1.3c

## Development

Sources for this package are [available on GitHub.][github]
This package is built with the [Nix][nix] package manager.

- Build a release directory with rendered PDFs:
  `nix build .#changelog`
- Build a release tarball:
  `nix build .#changelog-tar`, or just `nix build`
- Enter a development shell with `latexmk` and fonts available:
  `nix develop`

[keepachangelog.com]: https://keepachangelog.com/
[changelog]: https://ctan.org/pkg/changelog
[github]: https://github.com/9999years/latex-changelog
[nix]: https://zero-to-nix.com/
