# The Linux-only half. The enable/flavor/accent toggle and the single
# permitted module import live in home/common/catppuccin.nix.
{ pkgs, ... }:
{
  catppuccin = {
    # Mirrors `enable` to silence catppuccin/nix's migration warning. Stays
    # Linux-only: the darwin apps mostly ship hand-authored Mocha themes.
    autoEnable = true;

    # WhiteSur supplies the icons and cursor; this keeps only its GTK colors.
    gtk.icon.enable = false;
  };

  # Cursor assets only. The icon theme comes from home/linux/icons.
  home.packages = [ pkgs.whitesur-cursors ];

  # home.pointerCursor covers GTK, X resources and Wayland env vars at once.
  # Size 24, not home-manager's 32, which is larger than macOS's pointer.
  home.pointerCursor = {
    enable = true;
    name = "WhiteSur-cursors";
    package = pkgs.whitesur-cursors;
    size = 24;
  };
}
