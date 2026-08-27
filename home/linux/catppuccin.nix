# Catppuccin Frappe GTK theming + WhiteSur icons/cursors, shared by every
# NixOS host.
{
  inputs,
  pkgs,
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
    # top of Catppuccin's GTK colors). cursors stays disabled: WhiteSur's
    # cursor covers that instead.
    gtk.icon.enable = false;

    # delta and bat are themed in home/common (git/delta.nix, bat/default.nix);
    # disable the module's ports here so they aren't double-themed on Linux.
    delta.enable = false;
    bat.enable = false;
  };

  # Plain icon-theme/cursor-theme assets: SVGs, PNGs, an index.theme file.
  home.packages = with pkgs; [
    whitesur-icon-theme
    whitesur-cursors
  ];

  # Lowercase "dark" is whitesur-icon-theme's own directory casing
  # (share/icons/WhiteSur-dark/) - a different package from
  # whitesur-gtk-theme's "WhiteSur-Dark" used in cosmic/gtk.nix, not an
  # inconsistency to unify.
  gtk.iconTheme = {
    name = "WhiteSur-dark";
    package = pkgs.whitesur-icon-theme;
  };

  # home.pointerCursor, not gtk.cursorTheme directly - home-manager's
  # cross-toolkit option (GTK, X resources, Wayland env vars). size 24
  # instead of home-manager's default of 32, which renders noticeably
  # larger than macOS's pointer.
  home.pointerCursor = {
    enable = true;
    name = "WhiteSur-cursors";
    package = pkgs.whitesur-cursors;
    size = 24;
  };
}
