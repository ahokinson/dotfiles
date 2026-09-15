# COSMIC's Power applet opens a lock/logout/restart/shutdown menu; wlogout
# is the wlroots-ecosystem equivalent, opened from waybar.nix's power icon.
# No suspend entry - matches idle.nix's never-suspend policy.
{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        text = "Lock";
        keybind = "l";
        action = "loginctl lock-session";
      }
      {
        label = "logout";
        text = "Log out";
        keybind = "e";
        action = "swaymsg exit";
      }
      {
        label = "reboot";
        text = "Reboot";
        keybind = "r";
        action = "systemctl reboot";
      }
      {
        label = "shutdown";
        text = "Shutdown";
        keybind = "s";
        action = "systemctl poweroff";
      }
    ];
  };
}
