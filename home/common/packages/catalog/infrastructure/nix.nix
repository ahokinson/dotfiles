{ pkgs, ... }:
with pkgs;
[
  # nh itself is configured by home/common/infrastructure/nix/nh.nix.
  nix-diff
  nix-melt
  nix-output-monitor
  nix-tree
  nurl
  nvd
]
