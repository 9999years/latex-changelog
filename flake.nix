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

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) stdenv fetchzip;
      in
      {
        packages = {
          charter =
            let
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

              # WOFF2 fonts seem to cause problems on Linux; disable them by
              # default.
              enableWoff2 = false;

              installPhase = ''
                mkdir -p $out/share/fonts
                mv "OTF format (best for Mac OS)/Charter" $out/share/fonts/opentype
                mv "TTF format (best for Windows)/Charter" $out/share/fonts/truetype
                if [[ -n "$enableWoff2" ]]; then
                  mv "WOFF2 format (best for web)/Charter" $out/share/fonts/woff
                fi
                mv "Charter license.txt" $out/LICENSE.txt
              '';
            };

          changelog =
            let
              name = "changelog";
              versionSentinel = "[[VERSION]]";
              version = "2.5.1";
              dateSentinel = "[[DATE]]";
              date = "2024/09/17";
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
                  inherit (pkgs.texlive)
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
              FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ self.packages.${system}.charter ]; };

              pdf = true;

              distSrcs = [
                "LICENSE.txt"
                "README.md"
                "screenshot.png"
                "src/*.pdf"
                "src/changelog.sty"
                "src/changelog.tex"
                "src/example.tex"
              ];

              buildPhase = ''
                # Replace version sentinel.
                sd --string-mode '${versionSentinel}' '${version}' src/*.tex src/*.sty
                sd --string-mode '${dateSentinel}' '${date}' src/*.tex src/*.sty

                # Render PDFs.
                if [[ -n "$pdf" ]]; then
                  latexmk \
                    -r ./latexmkrc \
                    -pvc- -pv- \
                    src/*.tex
                fi
              '';

              installPhase = ''
                mkdir -p $out/${name}
                cp $distSrcs $out/${name}
              '';
            };

          changelog-no-pdf = self.packages.${system}.changelog.overrideAttrs (_prev: {
            pdf = false;
          });

          changelog-tar = stdenv.mkDerivation {
            name = "${self.packages.${system}.changelog.name}.tar.gz";
            version = self.packages.${system}.changelog.version;

            src = self.packages.${system}.changelog;

            phases = "unpackPhase installPhase";

            installPhase = ''
              tar --create --gzip --file $out *
              tar --verbose --list --file $out
            '';
          };

          default = self.packages.${system}.changelog-tar;
        };

        checks = self.packages.${system};

        devShells = {
          changelog = pkgs.mkShell {
            name = "latex-changelog";
            packages = [
              pkgs.texlab # TeX language server
              pkgs.just # Command runner
            ];
            inputsFrom = [
              self.packages.${system}.changelog
            ];
            FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ self.packages.${system}.charter ]; };
          };

          default = self.devShells.${system}.changelog;
        };
      }
    );
}
