{
  config,
  inputs,
  selfPath,
  username,
  ...
}:
let
  hostFacts = import (selfPath "home/common/lib/host.nix") { osConfig = config; };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (selfPath "modules/shared/nix/home-manager.nix")
  ];

  home-manager = {
    users.${username}.imports = [
      (selfPath "home/common")
      (selfPath "home/linux")
      (selfPath "home/linux/desktop/sessions/cosmic")
      (selfPath "home/linux/desktop/sessions/sway")
      inputs.cosmic-manager.homeManagerModules.cosmic-manager
      inputs.zen-browser.homeModules.beta
    ];
    # cosmic-greeter (modules/nixos/desktop/cosmic.nix) draws both the login
    # and lock screens as its own process under /var/lib/cosmic-greeter, with
    # no config of its own - just wallpaper.nix and theme.nix, so it matches
    # the desktop instead of falling back to COSMIC's stock look.
    users.cosmic-greeter = {
      imports = [
        (selfPath "home/linux/desktop/sessions/cosmic/wallpaper.nix")
        (selfPath "home/linux/desktop/sessions/cosmic/theme.nix")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
      ];
      # cosmic-manager's own switch, not services.desktopManager.cosmic.enable -
      # gates whether it writes any config at all.
      wayland.desktopManager.cosmic.enable = true;
      home.username = "cosmic-greeter";
      home.homeDirectory = "/var/lib/cosmic-greeter";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = {
      inherit
        inputs
        selfPath
        username
        hostFacts
        ;
    };
  };

  # cosmic-greeter-daemon is one long-lived process for the whole boot; it
  # renders login, lock and wake screens from whatever config it read at its
  # own start, not live from disk. Restart it whenever this generation
  # changes so a rebuild's wallpaper/theme actually reaches those screens.
  systemd.services.cosmic-greeter-daemon.restartTriggers = [
    config.home-manager.users.cosmic-greeter.home.activationPackage
  ];
}
