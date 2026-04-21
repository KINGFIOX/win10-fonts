{
  description = "Windows fonts packaged as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

        # Keep only font-like files from the windows/ folder.
        isFontFile =
          name: type:
          type == "regular"
          && (
            pkgs.lib.hasSuffix ".ttf" name
            || pkgs.lib.hasSuffix ".ttc" name
            || pkgs.lib.hasSuffix ".otf" name
            || pkgs.lib.hasSuffix ".otc" name
            || pkgs.lib.hasSuffix ".fon" name
            || pkgs.lib.hasSuffix ".fnt" name
          );

        fontSrc = pkgs.lib.cleanSourceWith {
          src = ./windows;
          filter = isFontFile;
        };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "windows-fonts-local";
          version = "1.0.0";
          src = fontSrc;
          dontUnpack = true;

          installPhase = ''
            runHook preInstall
            install -d "$out/share/fonts/truetype"
            cp -v "$src"/* "$out/share/fonts/truetype/"
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Local Windows font bundle from this repository";
            platforms = platforms.all;
          };
        };

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "list-fonts-in-package" ''
            echo "Built package content:"
            ls -lah ${self.packages.${system}.default}/share/fonts/truetype
          ''}";
        };
      }
    );
}
