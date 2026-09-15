{ pkgs, ... }:
with pkgs;
[
  dive
  # The macOS VM is configured in home/darwin/development/podman.nix; NixOS
  # runs it natively and rootless.
  podman
]
