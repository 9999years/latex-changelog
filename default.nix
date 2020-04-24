{ pkgs ? import <nixpkgs> { }, }:
let
  inherit (pkgs) stdenv lib;
  pkg = "changelog";
  versionSentinel = "\${VERSION}$";
  build = { pdf ? true, tar ? true, ... }:
    stdenv.mkDerivation rec {
      name = "latex-${pkg}";
      version = "2020/04/23 2.2.1";

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
        sd --string-mode '${versionSentinel}' '${version}' *.tex *.sty
        ${lib.optionalString pdf "${latexmk} *.tex"}

        rm -rf ${pkg}
        mkdir ${pkg}
        cp $distSrcs ${pkg}
      '';

      installPhase = ''
        ${if tar then ''
          tar -czf ${pkg}.tar.gz ${pkg}
          tar -tvf ${pkg}.tar.gz
          cp ${pkg}.tar.gz $out
        '' else ''
          mkdir -p $out
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
  dir-pdf = build { tar = false; };
}
