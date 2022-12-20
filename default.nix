let
  inherit (builtins) fetchTree fromJSON readFile;
  inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix kubo;
in
  {
    pkgs ? (
      import (fetchTree nixpkgs.locked) {
        overlays = [(import "${fetchTree gomod2nix.locked}/overlay.nix")];
      }
    ),
    src,
    version,
  }:
    pkgs.buildGoApplication {
      inherit src version;
      pname = "kubo";
      modules = ./gomod2nix.toml;
    }
