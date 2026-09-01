{ username, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required since the multi-user migration: this is the user that
  # user-scoped system.defaults (dock, finder, NSGlobalDomain) apply to.
  system.primaryUser = username;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
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
