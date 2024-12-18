# Build the release `.tar.gz` with Nix and write a `changelog.tar.gz` symlink pointing to it.
tar:
    nix build --out-link changelog.tar.gz

# Build the release directory (without `tar`ing it) and link `changelog` to it.
dir:
    nix build .#changelog --out-link changelog

# Build the release directory (without `tar`ing it or generating PDFs) and link `changelog` to it.
dir-no-pdf:
    nix build .#changelog-no-pdf --out-link changelog

# Clean LaTeX output files.
clean:
    latexmk -pvc- -C src/*.tex

# Compile `src/changelog.tex` with `latexmk`, recompiling when it changes.
watch:
    latexmk -pvc src/changelog.tex
