# COSMIC desktop on NixOS (framework13 host). Asahi hosts stay on Plasma —
# see desktop-plasma.nix, still imported by home/linux/plasma-panel.nix +
# plasma-theme.nix there.
#
# The COSMIC module already enables graphical-desktop, dconf, polkit, rtkit,
# accounts-daemon, libinput, upower, geoclue2, XDG portals, and mkDefaults
# Bluetooth / NetworkManager / GVFS / gnome-keyring / power-profiles-daemon.
# xwayland.enable defaults to true, so services.xserver.enable is not needed.
{ ... }: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Framework hardware wants fwupd for BIOS/EC updates. The COSMIC module
  # doesn't enable it by default (Plasma used to pull it in for free), so
  # it's explicit here. Its upstream fwupd-refresh.service doesn't declare
  # After=polkit.service: if the refresh timer fires while a nixos-rebuild
  # switch is restarting polkit/dbus-broker, fwupdmgr loses the race
  # ("PolicyKit daemon is not available") and the unit fails.
  services.fwupd.enable = true;
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };
}
