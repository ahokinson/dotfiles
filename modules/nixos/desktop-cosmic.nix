# The COSMIC module already brings graphical-desktop, dconf, polkit, rtkit,
# accounts-daemon, libinput, upower, geoclue2, XDG portals and xwayland, and
# mkDefaults Bluetooth/NetworkManager/GVFS/gnome-keyring/power-profiles-daemon.
{ pkgs, ... }: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Bundled apps that duplicate something already installed. Only ever
  # exclude from this list; excluding from the module's corePkgs breaks the
  # session.
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit # nvim
    cosmic-monitor # btop
    cosmic-player
    cosmic-reader
    cosmic-term # ghostty
    networkmanagerapplet
  ];

  # fwupd-refresh's upstream unit has no After=polkit.service, so a refresh
  # firing mid-switch, while polkit restarts, fails with "PolicyKit daemon is
  # not available".
  services.fwupd.enable = true;
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };
}
