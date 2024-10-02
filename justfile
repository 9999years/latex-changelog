tar:
    nix build

dir:
    nix build .#changelog

dir-no-pdf:
    nix build .#changelog-no-pdf
