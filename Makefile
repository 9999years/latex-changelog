# Some helper targets for development.
# See `flake.nix` for the definitions used to actually build the package.

clean:
	latexmk -pvc- -C
.PHONY: clean

watch:
	latexmk -pvc changelog.tex
.PHONY: watch

# Not used in the real build but defined here for convenience.
changelog.pdf: changelog.tex
	latexmk -pvc- changelog.tex

example.pdf: example.tex
	latexmk -pvc- example.tex

changelog.tar.gz:
	nix build ".#changelog-tar" --out-link changelog.tar.gz
