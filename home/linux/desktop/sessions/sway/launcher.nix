# fuzzel over wofi (low-maintenance) or rofi (X11-native, needs the Wayland
# fork): actively maintained and has first-class catppuccin/nix support, so
# catppuccin.autoEnable themes it for free.
{
  programs.fuzzel.enable = true;

  # fuzzel doesn't read GTK/dconf's icon-theme setting - unset, its
  # icon-theme key defaults to the literal string "default" (fuzzel.ini(5)),
  # which resolves to stock/hicolor icons. Point it at the same theme
  # home/linux/desktop/icons installs everywhere else.
  programs.fuzzel.settings.main.icon-theme = "WhiteSur-dark-catppuccin";
}
