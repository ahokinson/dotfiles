{
  inputs,
  selfPath,
  username,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Back up pre-existing real files rather than hard-failing on them.
    backupFileExtension = "hm-backup";
    users.${username} = {
      imports = [
        (selfPath "home/common")
        (selfPath "home/linux")
        (selfPath "home/linux/cosmic")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.zen-browser.homeModules.beta
      ];
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
    };
    # cosmic-greeter (modules/nixos/desktop-cosmic.nix) draws both the login
    # and lock screens as its own process under /var/lib/cosmic-greeter, with
    # no config of its own - just wallpaper.nix and theme.nix, so it matches
    # the desktop instead of falling back to COSMIC's stock look.
    users.cosmic-greeter = {
      imports = [
        (selfPath "home/linux/cosmic/wallpaper.nix")
        (selfPath "home/linux/cosmic/theme.nix")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
      ];
      # cosmic-manager's own switch, not services.desktopManager.cosmic.enable -
      # gates whether it writes any config at all.
      wayland.desktopManager.cosmic.enable = true;
      home.username = "cosmic-greeter";
      home.homeDirectory = "/var/lib/cosmic-greeter";
      home.stateVersion = "26.05";
    };
    # username is unused under home/ so far; kept so both platforms hand
    # their home modules the same argument set.
    extraSpecialArgs = { inherit inputs selfPath username; };
  };
}
