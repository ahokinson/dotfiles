# Sway as a second, selectable Wayland session alongside COSMIC
# (desktops/cosmic.nix). programs.sway.enable registers sway.desktop through
# services.displayManager.sessionPackages - the same mechanism cosmic.desktop
# already goes through - and adds the wlroots portal to the system portal
# set. Graphics, dconf, the polkit daemon and xdg.portal.enable are already
# on system-wide via COSMIC's module chain; nothing here duplicates that.
{
  lib,
  pkgs,
  username,
  ...
}:
let
  # cosmic-greeter starts an authenticated session directly from a desktop
  # entry. Its launcher does not resolve Sway's upstream `Exec=sway` reliably,
  # so use the same binary through an absolute store path. `providedSessions`
  # makes this the sole normal Sway entry; `programs.sway.package = null`
  # prevents the upstream relative-Exec entry from being registered too.
  swaySession =
    (pkgs.writeTextDir "share/wayland-sessions/sway.desktop" ''
      [Desktop Entry]
      Name=Sway
      Comment=An i3-compatible Wayland compositor
      Exec=${lib.getExe pkgs.sway}
      Type=Application
      DesktopNames=sway
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "sway" ];
      });
in
{
  programs.sway.enable = true;
  programs.sway.package = null;
  # Drop the module's default extraPackages (foot, dmenu, swaylock,
  # swayidle, xwayland) - home/linux/desktop/sessions/sway already covers each: ghostty is
  # the terminal, fuzzel the launcher, cosmic-greeter-daemon does locking
  # via ext-session-lock-v1, swayidle is disabled in idle.nix, and xwayland
  # is enabled directly in compositor.nix.
  programs.sway.extraPackages = lib.mkForce [ ];

  environment.systemPackages = [ pkgs.sway ];
  services.displayManager.sessionPackages = [ swaySession ];

  # brightnessctl (home/linux/desktop/sessions/sway/compositor.nix's XF86MonBrightness binds)
  # needs its udev rule and the video group to write brightness without
  # root - home.packages alone doesn't wire the udev rule in. swayosd
  # (home/linux/desktop/sessions/sway/osd.nix) ships its own udev rule for the same reason.
  services.udev.packages = [
    pkgs.brightnessctl
    pkgs.swayosd
  ];
  users.users.${username}.extraGroups = [ "video" ];
}
