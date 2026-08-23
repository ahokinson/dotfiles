# COSMIC desktop (NixOS-level enablement; framework13 is the only NixOS
# host — Asahi's COSMIC install is dnf-managed, outside this repo). The
# COSMIC module already enables
# graphical-desktop, dconf, polkit, rtkit, accounts-daemon, libinput, upower,
# geoclue2, XDG portals, and mkDefaults Bluetooth/NetworkManager/GVFS/
# gnome-keyring/power-profiles-daemon; xwayland.enable defaults to true.
{ ... }: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # COSMIC doesn't enable fwupd by default (Plasma used to pull it in).
  # fwupd-refresh's upstream unit doesn't declare After=polkit.service, so a
  # refresh firing mid-switch (while polkit restarts) fails on "PolicyKit
  # daemon is not available" without this.
  services.fwupd.enable = true;
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };
}
