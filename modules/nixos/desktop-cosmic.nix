# COSMIC desktop (NixOS-level enablement), shared by every NixOS host
# (framework13-amd-ryzen, bookpro14-m1-pro, studio-m1-max). The COSMIC
# module already enables
# graphical-desktop, dconf, polkit, rtkit, accounts-daemon, libinput, upower,
# geoclue2, XDG portals, and mkDefaults Bluetooth/NetworkManager/GVFS/
# gnome-keyring/power-profiles-daemon; xwayland.enable defaults to true.
{ pkgs, ... }: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Bundled apps the COSMIC module installs that duplicate something better
  # already on the box. networkmanagerapplet is the module's own: its
  # nm-connection-editor overlaps Settings' network pages and its nm-applet
  # overlaps the panel applet. Excluding anything from the module's corePkgs
  # list instead would break the session.
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit # nvim
    cosmic-monitor # btop
    cosmic-player
    cosmic-reader
    cosmic-term # ghostty
    networkmanagerapplet
  ];

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
