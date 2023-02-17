# The `changelog` LaTeX package

[Available on CTAN as `changelog`][changelog]

Changelogs are important. The `changelog` package defines a `changelog`
environment to make changelogs simple and intuitive.

Inspired by [keepachangelog.com].

```latex
\begin{changelog}[author=Rebecca Turner, simple, sectioncmd=\section*]
\begin{version}[v=1.0.0, date=2018-12-28]
  \item Cool features
  \item Bug fixes
\end{version}
\shortversion{v=0.1.0, date=2018-10-25, changes=Initial beta}
\end{changelog}
```

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
