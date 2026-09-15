# The COSMIC module already brings graphical-desktop, dconf, polkit, rtkit,
# accounts-daemon, libinput, upower, geoclue2, XDG portals and xwayland, and
# mkDefaults Bluetooth/NetworkManager/GVFS/gnome-keyring/power-profiles-daemon.
{ config, lib, pkgs, ... }: {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # `sessionPackages` puts its generated desktop files in XDG_DATA_DIRS for
  # user sessions. cosmic-greeter's *login* process, however, is started by
  # greetd as the cosmic-greeter system user before a user session exists, so
  # it otherwise sees only its own package paths. The session picker visible
  # inside an already-running COSMIC session is not a compositor switcher;
  # without this directory the real login greeter cannot launch Sway (or any
  # other extra session) at all.
  services.greetd.settings.default_session.command = lib.mkForce (
    lib.concatStringsSep " " [
      (lib.getExe' pkgs.coreutils "env")
      ''XCURSOR_THEME="''${XCURSOR_THEME:-Pop}"''
      "XDG_DATA_DIRS=${config.services.displayManager.sessionData.desktops}/share"
      (lib.getExe' config.services.displayManager.cosmic-greeter.package "cosmic-greeter-start")
    ]
  );

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
