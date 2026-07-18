{
  description = "CHROMA Quickshell development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              quickshell
              jq
              playerctl
              wireplumber
              brightnessctl
              wl-clipboard
              cliphist
              libnotify
              cava
              networkmanager
              bluez
              grim
              slurp
            ];
          };
        });
    };
}
