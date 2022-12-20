(import
  (
    let
      inherit (builtins) fromJSON readFile fetchTarball;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) flake-compat;
    in
      fetchTarball (with flake-compat.locked; {
        url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = narHash;
      })
  ) {src = ./.;})
.shellNix
