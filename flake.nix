{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kubo = {
      url = "github:ipfs/kubo";
      flake = false;
    };
    gomod2nix = {
      url = "github:tweag/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    flake-utils,
    ...
  } @ inputs: (
    flake-utils.lib.eachDefaultSystem
    (system: let
      inherit (pkgs) lib;
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.gomod2nix.overlays.default
          inputs.devshell.overlay
        ];
      };
    in {
      packages.default = pkgs.callPackage ./. {
        src = inputs.kubo;
        version = inputs.kubo.rev;
      };
      packages.kubo = self.packages.${system}.default;

      checks.kubo = self.packages.${system}.kubo;

      devShells.default = pkgs.devshell.mkShell {
        commands = with pkgs; [
          {
            name = "generate-gomod2nix";
            command = "gomod2nix --dir ${inputs.kubo} --outdir ./";
          }
        ];
        packages = with pkgs; [
          alejandra
          gomod2nix
          taplo-cli
          treefmt
        ];
      };
    })
  );
}
