{ username, selfPath, ... }: {
  imports = [ (selfPath "modules/nix-settings.nix") ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required since the multi-user migration: this is the user that
  # user-scoped system.defaults (dock, finder, NSGlobalDomain) apply to.
  system.primaryUser = username;

  nix.gc = {
    automatic = true;
    interval = [
      {
        Weekday = 0;
        Hour = 3;
        Minute = 15;
      }
    ];
    options = "--delete-older-than 14d";
  };

  # Determinate Nix uses 350, not nix-darwin's historical 30000. A mismatch
  # aborts activation.
  ids.gids.nixbld = 350;

  system.stateVersion = 4;
}
