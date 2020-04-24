{ pkgs ? import <nixpkgs> { }, }:
let
  inherit (pkgs) stdenv lib;
  pkg = "changelog";
  build = { pdf ? true, tar ? true, ... }:
    stdenv.mkDerivation rec {
      name = "latex-${pkg}";
      version = "2020/04/23 2.2.0";

      buildInputs = with pkgs; [
        (texlive.combine rec {
          inherit (texlive)
            scheme-small collection-xetex latexmk collection-latexrecommended
            ltxguidex translations framed enumitem showexpl babel babel-german
            babel-english changepage fira varwidth;
        })
        fd
        sd
        just
      ];

      src = ./.;
      distSrcs = [
        "changelog.sty"
        "changelog.tex"
        "example.tex"
        "LICENSE.txt"
        "README.md"
        "screenshot.png"
        "*.pdf"
      ];

      dontConfigure = true;
      buildPhase = let latexmk = "latexmk -pdf -r ./latexmkrc -pvc- -pv-";
      in ''
        sd --string-mode '${""}''${VERSION}$' ${version}
        ${lib.optionalString pdf "${latexmk} *.tex"}

        mkdir -p ${pkg}
        cp $distSrcs ${pkg}
      '';

      installPhase = ''
        mkdir -p $out
        ${if tar then

        ''
          tar -czf ${pkg}.tar.gz ${pkg}
          tar -tvf ${pkg}.tar.gz
          cp ${pkg}.tar.gz $out
        '' else ''
          cp -r ${pkg} $out
        ''}
      '';
    };
in {
  tar = build { };
  dir = build {
    pdf = false;
    tar = false;
  };
}
