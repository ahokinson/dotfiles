# Linux-only home config. Imported by both NixOS hosts (via the host's
# home-manager section) and the standalone Asahi home-manager profile.
# Use `osConfig`/`config ? osConfig` to gate items to one context.
{ inputs, pkgs, lib, config, ... }: {
  imports = [
    ./packages.nix
    ./catppuccin.nix
  ];
}