# Build the release `.tar.gz` with Nix and write a `changelog.tar.gz` symlink pointing to it.
tar:
    nix build --out-link changelog.tar.gz

dir:
    nix build .#changelog --out-link changelog

dir-no-pdf:
    nix build .#changelog-no-pdf --out-link changelog

clean:
    latexmk -pvc- -C src/*.tex

watch:
    latexmk -pvc src/changelog.tex
