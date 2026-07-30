{ pkgs, ... }: {
  # hermes-agent binary comes from the hermes-agent flake input via overlays/default.nix.
  # On NixOS it's also activated as a system service via modules/nixos/hermes.nix.
  home.packages = [ pkgs.hermes-agent ];

  # Hermes reads its config from ~/.hermes/
  home.file.".hermes" = {
    source = ./config-files;
    recursive = true;
  };
}