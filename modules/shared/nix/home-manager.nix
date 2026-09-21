# Shared between NixOS and Darwin: imported by modules/nixos/user/home-manager.nix
# and modules/darwin/user/home-manager.nix, which each add their own
# home-manager module import, extra imports/sharedModules, and (nixos only)
# the cosmic-greeter profile.
{ config, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Back up pre-existing real files rather than hard-failing on them.
    backupFileExtension = "hm-backup";
    users.${username} = {
      home.username = username;
      home.homeDirectory = config.users.users.${username}.home;
      home.stateVersion = "26.05";
    };
  };
}
