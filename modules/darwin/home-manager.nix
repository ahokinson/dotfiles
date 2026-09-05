{
  inputs,
  selfPath,
  config,
  username,
  ...
}:
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Back up pre-existing real files rather than hard-failing on them.
    backupFileExtension = "hm-backup";
    users.${username} = {
      imports = [
        inputs.zen-browser.homeModules.beta
        (selfPath "home/common")
        (selfPath "home/darwin")
      ];
      home.username = username;
      home.homeDirectory = config.users.users.${username}.home;
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs selfPath username; };
  };
}
