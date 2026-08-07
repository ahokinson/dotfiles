# Linux-only home config. Imported by both NixOS hosts (via the host's
# home-manager section) and the standalone Asahi home-manager profile.
# Take `osConfig ? null` as a module arg and check `osConfig != null` to
# gate items to one context - it's a specialArg home-manager injects only
# when wired in as a NixOS module, not a `config` option (see packages.nix,
# ../linux/plasma-panel.nix).
{ selfPath, pkgs, lib, config, ... }: {
  imports = [
    (selfPath "home/linux/packages.nix")
    (selfPath "home/linux/catppuccin.nix")
    (selfPath "home/linux/wallpaper.nix")
    (selfPath "home/linux/zen-browser.nix")
    (selfPath "home/linux/desktop-file-trust.nix")
  ];
}
