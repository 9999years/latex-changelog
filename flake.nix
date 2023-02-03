# Format this file with `alejandra`.
# Build a release directory with rendered PDFs: `nix build .#changelog`
# Build a release tarball: `nix build`
# Enter a development shell: `nix develop`
{
  description = "The LaTeX `changelog` package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ attrs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) stdenv lib fetchzip fontconfig;
      in rec {
        packages = {
          charter = let
            version = "210112";
          in
            stdenv.mkDerivation {
              pname = "charter";
              inherit version;

              src = fetchzip {
                url = "https://practicaltypography.com/fonts/Charter%20${version}.zip";
                name = "Charter-${version}.zip";
                hash = "sha256-rsKMp+LBEitOFPgM1xF//BLgF3uIRPlBitLdrefmsnw=";
              };

              phases = "unpackPhase installPhase";

              installPhase = ''
                mkdir -p $out/share/fonts
                mv "OTF format (best for Mac OS)/Charter" $out/share/fonts/opentype
                mv "TTF format (best for Windows)/Charter" $out/share/fonts/truetype
                mv "WOFF2 format (best for web)/Charter" $out/share/fonts/woff
                mv "Charter license.txt" $out/LICENSE.txt
              '';
            };

          changelog = let
            name = "changelog";
            versionSentinel = "\${VERSION}$";
            version = "2020/08/26 2.4.0";
          in
            stdenv.mkDerivation {
              name = "latex-${name}";
              inherit version;

              src = ./.;

              buildInputs = [
                # We could just use `scheme-full` here, but that's 3.8GB and
                # this is only like 0.4GB. I guess it is worth enumerating the
                # packages manually.
                (pkgs.texlive.combine {
                  inherit
                    (pkgs.texlive)
                    scheme-small
                    collection-xetex
                    latexmk
                    collection-latexrecommended
                    ltxguidex
                    translations
                    framed
                    enumitem
                    showexpl
                    babel
                    babel-german
                    babel-english
                    changepage
                    fira
                    varwidth
                    ;
                })

                pkgs.sd
              ];

              phases = "unpackPhase buildPhase installPhase";

              # This lets XeLaTeX pick up the font directories.
              # https://github.com/NixOS/nixpkgs/issues/24485#issuecomment-290758573
              FONTCONFIG_FILE = pkgs.makeFontsConf {fontDirectories = [packages.charter];};

              pdf = true;

              distSrcs = [
                "changelog.sty"
                "changelog.tex"
                "example.tex"
                "LICENSE.txt"
                "README.md"
                "screenshot.png"
                "*.pdf"
              ];

              buildPhase = ''
                # Replace version sentinel.
                sd --string-mode '${versionSentinel}' '${version}' *.tex *.sty

                # Render PDFs.
                if [[ -n "$pdf" ]]; then
                  latexmk -pdf -r ./latexmkrc -pvc- -pv- *.tex
                fi
              '';

              installPhase = ''
                mkdir -p $out/${name}
                cp $distSrcs $out/${name}
              '';
            };

          changelog-tar = let
            name = "changelog";
          in
            stdenv.mkDerivation {
              name = "${packages.changelog.name}.tar.gz";
              version = packages.changelog.version;

              src = packages.changelog;

              phases = "unpackPhase installPhase";

              installPhase = ''
                tar -cvf $out *
                tar -tvf $out
              '';
            };

          default = packages.changelog-tar;
        };

        devShells = {
          changelog = pkgs.mkShell {
            name = "latex-changelog";
            packages = [];
            inputsFrom = [
              packages.changelog
            ];
            FONTCONFIG_FILE = pkgs.makeFontsConf {fontDirectories = [packages.charter];};
          };

          default = devShells.changelog;
        };
      }
    );
}
