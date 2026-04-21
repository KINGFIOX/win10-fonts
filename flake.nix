{
  description = "Win10 fonts packaged as a reusable Nix flake";

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
    let
      perSystem = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Keep only font-like files from the win10/ folder.
          isFontFile =
            path: type:
            let
              name = pkgs.lib.toLower (baseNameOf path);
            in
            type == "regular"
            && builtins.any (ext: pkgs.lib.hasSuffix ext name) [
              ".ttf"
              ".ttc"
              ".otf"
              ".otc"
              ".fon"
              ".fnt"
            ];

          fontSrc = pkgs.lib.cleanSourceWith {
            src = ./win10;
            filter = path: type: type == "directory" || isFontFile path type;
          };
        in
        {
          packages.win10-fonts = pkgs.stdenvNoCC.mkDerivation {
            pname = "win10-fonts";
            version = "1.0.0";
            src = fontSrc;
            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              install -d "$out/share/fonts/truetype"
              cp -vr "$src"/. "$out/share/fonts/truetype/"
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Windows fonts bundled from local win10 directory";
              platforms = platforms.all;
            };
          };

          packages.default = self.packages.${system}.win10-fonts;

          apps.default = {
            type = "app";
            program = "${pkgs.writeShellScript "list-fonts-in-package" ''
              echo "Built package content:"
              ls -lah ${self.packages.${system}.default}/share/fonts/truetype
            ''}";
            meta = {
              description = "List packaged font files";
            };
          };
        }
      );
    in
    perSystem
    // {
      overlays.default = final: prev: {
        win10-fonts = self.packages.${prev.system}.win10-fonts;
      };

      nixosModules.default =
        {
          pkgs,
          ...
        }:
        {
          fonts.packages = [ self.packages.${pkgs.system}.win10-fonts ];
        };
    };
}
