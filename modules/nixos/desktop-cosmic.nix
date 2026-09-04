# The COSMIC module already brings graphical-desktop, dconf, polkit, rtkit,
# accounts-daemon, libinput, upower, geoclue2, XDG portals and xwayland, and
# mkDefaults Bluetooth/NetworkManager/GVFS/gnome-keyring/power-profiles-daemon.
{
  config,
  pkgs,
  selfPath,
  ...
}:
let
  # Mirrors home/linux/cosmic/wallpaper.nix's own host selection.
  wallpaper = selfPath (
    if config.hardware.asahi.enable or false then
      "home/common/_files/wallpaper/asahi.jpg"
    else
      "home/common/_files/wallpaper/nix.jpg"
  );
  backgroundAll = pkgs.writeText "cosmic-greeter-background-all" ''
    (
        filter_by_theme: false,
        filter_method: Lanczos,
        output: "all",
        rotation_frequency: 0,
        sampling_method: Alphanumeric,
        scaling_mode: Zoom,
        source: Path(
            "${wallpaper}",
        ),
    )'';
  backgroundSameOnAll = pkgs.writeText "cosmic-greeter-background-same-on-all" "true";
  greeterDir = {
    user = "cosmic-greeter";
    group = "cosmic-greeter";
    mode = "0750";
  };
in
{
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

  # The pre-auth login tile reads the real user's own wallpaper config
  # straight off disk, but locking a running session spawns a separate
  # cosmic-greeter process that only has /var/lib/cosmic-greeter's own
  # (otherwise empty) config to look at, so it falls back to the stock
  # cosmic-wallpapers image. Give that user the same background config
  # anders already has, so lock matches login and desktop.
  systemd.tmpfiles.settings."cosmic-greeter-wallpaper" = {
    "/var/lib/cosmic-greeter/.config".d = greeterDir;
    "/var/lib/cosmic-greeter/.config/cosmic".d = greeterDir;
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground".d = greeterDir;
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1".d = greeterDir;
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1/all"."L+".argument = "${
      backgroundAll
    }";
    "/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all"."L+".argument =
      "${backgroundSameOnAll}";
  };
}
