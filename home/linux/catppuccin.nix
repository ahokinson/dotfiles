# Catppuccin Frappe GTK theming + WhiteSur icons/cursors for Linux. Applies
# to all Linux hosts (NixOS and Asahi Fedora) - GTK color theme + icon/cursor
# shape only. Qt/Kvantum theming is NixOS-only,
# see catppuccin-qt.nix: it installs Nix-built Qt platform-theme/Kvantum
# plugins and points Qt apps at them via env vars, which is only safe when
# the whole Plasma/Qt stack is also Nix-built (NixOS). On Asahi, Plasma is
# Fedora's own RPM-installed build using Fedora's system Qt - pointing it at
# Nix-built plugins is an ABI mismatch that crashes every Qt/Plasma process
# on load (confirmed: this exact config caused a DrKonqi crash-loop and
# login failure on real Asahi hardware).
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
    # Explicitly mirror `enable` into `autoEnable` to silence the
    # migration warning the catppuccin/nix module emits when only
    # `catppuccin.enable` is set (see modules/global.nix).
    autoEnable = true;
    flavor = "frappe";
    accent = "mauve";

    # `gtk.icon` defaults to catppuccin.autoEnable (true) but is turned off
    # below in favor of WhiteSur, for macOS-shaped icons/cursors on top of
    # Catppuccin's GTK colors - see gtk.iconTheme/home.pointerCursor below.
    # `cursors` already opts out of auto-enable and is deliberately left
    # disabled - the Catppuccin cursor theme isn't good, and now WhiteSur's
    # cursor covers that instead. `kvantum` is left to catppuccin-qt.nix on
    # hosts that import it.
    gtk.icon.enable = false;

    # delta and bat are themed in home/common (git/default.nix, bat/default.nix);
    # disable the module's ports here so they aren't double-themed on Linux.
    delta.enable = false;
    bat.enable = false;
  };

  # macOS-shaped icons/cursors (Phase 2 of the COSMIC migration plan) on top
  # of Catppuccin's GTK color theme above - "WhiteSur but Catppuccin where
  # possible". Plain icon-theme/cursor-theme assets (SVGs, PNGs, an
  # index.theme file), no compiled ABI-sensitive code, so safe to share with
  # Asahi's foreign-distro Plasma the same way catppuccin's own icon theme
  # was (unlike catppuccin-qt.nix's Kvantum plugins).
  #
  # Package names/theme names verified against nixpkgs's
  # pkgs/by-name/wh/whitesur-icon-theme and whitesur-cursors derivations and
  # upstream WhiteSur-icon-theme's install.sh: with no themeVariants given,
  # install.sh installs "WhiteSur", "WhiteSur-light", and "WhiteSur-dark"
  # (lowercase suffix); whitesur-cursors installs a single
  # "WhiteSur-cursors" directory, no light/dark split.
  home.packages = with pkgs; [
    whitesur-icon-theme
    whitesur-cursors
  ];

  gtk.iconTheme = {
    name = "WhiteSur-dark";
    package = pkgs.whitesur-icon-theme;
  };

  # home.pointerCursor rather than gtk.cursorTheme directly - it's
  # home-manager's cross-toolkit option (expands to GTK, X resources, and
  # Wayland env vars), the same one catppuccin/nix's own cursors.nix module
  # uses.
  home.pointerCursor = {
    enable = true;
    name = "WhiteSur-cursors";
    package = pkgs.whitesur-cursors;
  };
}