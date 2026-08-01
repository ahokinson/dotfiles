# Linux-only home config. Imported by both NixOS hosts (via the host's
# home-manager section) and the standalone Asahi home-manager profile.
# Use `osConfig`/`config ? osConfig` to gate items to one context.
{ selfPath, pkgs, lib, config, ... }: {
  imports = [
    (selfPath "home/linux/packages.nix")
    (selfPath "home/linux/catppuccin.nix")
    (selfPath "home/linux/wallpaper.nix")
    (selfPath "home/linux/zen-browser.nix")
  ];
}
