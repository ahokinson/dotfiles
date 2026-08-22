# Catppuccin Frappe GTK theming + WhiteSur icons/cursors for Linux (NixOS
# and Asahi Fedora). Qt/Kvantum theming is NixOS-only (catppuccin-qt.nix):
# it points Qt apps at Nix-built platform-theme/Kvantum plugins via env
# vars, which is only ABI-safe when the whole Plasma/Qt stack is Nix-built
# too — on Asahi's Fedora-built Plasma this crashed every Qt process on
# load (confirmed on real hardware).
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    # Mirrors `enable` into `autoEnable` to silence catppuccin/nix's
    # migration warning.
    autoEnable = true;
    flavor = "frappe";
    accent = "mauve";

    # gtk.icon off in favor of WhiteSur below (macOS-shaped icons/cursors on
    # top of Catppuccin's GTK colors). cursors stays disabled — WhiteSur's
    # cursor covers that instead. kvantum is left to catppuccin-qt.nix on
    # hosts that import it.
    gtk.icon.enable = false;

    # delta and bat are themed in home/common (git/delta.nix, bat/default.nix);
    # disable the module's ports here so they aren't double-themed on Linux.
    delta.enable = false;
    bat.enable = false;
  };

  # Plain icon-theme/cursor-theme assets (SVGs, PNGs, an index.theme file),
  # no compiled ABI-sensitive code, so safe to share with Asahi's
  # foreign-distro Plasma unlike catppuccin-qt.nix's Kvantum plugins.
  home.packages = with pkgs; [
    whitesur-icon-theme
    whitesur-cursors
  ];

  gtk.iconTheme = {
    name = "WhiteSur-dark";
    package = pkgs.whitesur-icon-theme;
  };

  # home.pointerCursor rather than gtk.cursorTheme directly - home-manager's
  # cross-toolkit option (GTK, X resources, Wayland env vars). size 24
  # rather than home-manager's default of 32, which renders noticeably
  # larger than macOS's pointer.
  home.pointerCursor = {
    enable = true;
    name = "WhiteSur-cursors";
    package = pkgs.whitesur-cursors;
    size = 24;
  };
}
