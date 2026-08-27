# COSMIC desktop (NixOS-level enablement), shared by every NixOS host
# (framework13-amd-ryzen, bookpro14-m1-pro, studio-m1-max). The COSMIC
# module already enables
# graphical-desktop, dconf, polkit, rtkit, accounts-daemon, libinput, upower,
# geoclue2, XDG portals, and mkDefaults Bluetooth/NetworkManager/GVFS/
# gnome-keyring/power-profiles-daemon; xwayland.enable defaults to true.
_: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # COSMIC doesn't enable fwupd by default, so it's enabled explicitly here.
  # fwupd-refresh's upstream unit doesn't declare After=polkit.service, so a
  # refresh firing mid-switch (while polkit restarts) fails on "PolicyKit
  # daemon is not available" without this.
  services.fwupd.enable = true;
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };
}
