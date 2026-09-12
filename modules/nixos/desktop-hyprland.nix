# Hyprland as a second, selectable Wayland session alongside COSMIC
# (desktop-cosmic.nix). programs.hyprland.enable registers hyprland.desktop
# through services.displayManager.sessionPackages - the same mechanism
# cosmic.desktop already goes through - and adds xdg-desktop-portal-hyprland
# to the system portal set. Graphics, dconf, the polkit daemon and
# xdg.portal.enable are already on system-wide via COSMIC's module chain;
# nothing here duplicates that.
{ pkgs, username, ... }:
{
  programs.hyprland.enable = true;

  # hyprlock authenticates through PAM directly; with no PAM service of its
  # own it can never unlock the session.
  security.pam.services.hyprlock = { };

  # brightnessctl (home/linux/hyprland/compositor.nix's XF86MonBrightness
  # binds) needs its udev rule and the video group to write brightness
  # without root - home.packages alone doesn't wire the udev rule in.
  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.${username}.extraGroups = [ "video" ];
}
