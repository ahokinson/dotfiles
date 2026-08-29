# Catppuccin Frappe GTK theming + WhiteSur icons/cursors, shared by every
# NixOS host. The enable/flavor/accent toggle itself lives in
# home/common/catppuccin.nix (cross-platform, and the module import can only
# happen once); this file adds the Linux-only bits on top.
{ pkgs, ... }:
{
  catppuccin = {
    # Mirrors `enable` into `autoEnable` to silence catppuccin/nix's
    # migration warning. Linux-only: turning it on cross-platform would
    # auto-theme every other catppuccin/nix-supported app this repo installs
    # on darwin too, most of which already have their own hand-authored
    # Frappe theme files.
    autoEnable = true;

    # gtk.icon off in favor of WhiteSur below (macOS-shaped icons/cursors on
    # top of Catppuccin's GTK colors). cursors stays disabled: WhiteSur's
    # cursor covers that instead.
    gtk.icon.enable = false;
  };

  # Plain cursor-theme assets: SVGs, PNGs, an index.theme file. The icon
  # theme is installed by home/linux/icons instead, which wraps
  # WhiteSur-dark in a child theme carrying this repo's own app icons and
  # selects that for both GTK and COSMIC.
  home.packages = [ pkgs.whitesur-cursors ];

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
