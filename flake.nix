{
  description = "Latex flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full
            latex-bin
            latexmk
            tools
            ;
        };
      in
      rec {
        packages.default = pkgs.stdenvNoCC.mkDerivation rec {
          name = "pdf";
          src = ./.;
          buildInputs = [
            pkgs.coreutils
            pkgs.pretendard
            tex
          ];
          phases = [
            "unpackPhase"
            "buildPhase"
            "installPhase"
          ];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}"
            export TEMPDIR=$(mktemp -d)
            mkdir -p $TEMPDIR/.texcache/texmf-var
            env TEXMFHOME="$TEMPDIR/.texcache" \
              TEXMFVAR="$TEMPDIR/.texcache/texmf-var" \
              OSFONTDIR=${pkgs.ibm-plex}/share/fonts \
              latexmk -interaction=nonstopmode -pdf -lualatex \
              main.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/
          '';
        };
        devShells.default = pkgs.mkShell {
          buildInputs = packages.default.buildInputs;
        };
      }
    );
}
