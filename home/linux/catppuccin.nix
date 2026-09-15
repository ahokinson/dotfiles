# The Linux-only half. The enable/flavor/accent toggle and the single
# permitted module import live in home/common/catppuccin.nix.
{ pkgs, ... }:
{
  catppuccin = {
    autoEnable = false;

    # None of these have a theme of their own (unlike bat/delta in
    # home/common/catppuccin.nix) and none exist on darwin, so they opt in
    # here instead of there.
    fuzzel.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
    zathura.enable = true;

    # catppuccin/nix now provides only the Papirus icon variant under its GTK
    # namespace. GTK colors come from home/linux/cosmic/gtk.nix's WhiteSur
    # theme, so leave the Catppuccin icon variant disabled.
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
