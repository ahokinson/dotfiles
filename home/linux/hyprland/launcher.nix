# fuzzel over wofi (low-maintenance) or rofi (X11-native, needs the Wayland
# fork): actively maintained and has first-class catppuccin/nix support, so
# catppuccin.autoEnable themes it for free.
{
  programs.fuzzel.enable = true;
}
