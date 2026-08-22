{ ... }: {
  # Apple Silicon mac
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required since nix-darwin's multi-user migration: user-scoped
  # system.defaults options (dock, finder, NSGlobalDomain) apply to this user.
  system.primaryUser = "anders";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    interval = [{ Weekday = 0; Hour = 3; Minute = 15; }];
    options = "--delete-older-than 14d";
  };

  # Determinate Nix uses GID 350 for nixbld, not nix-darwin's historical
  # default of 30000 — must match the actual group or activation aborts.
  ids.gids.nixbld = 350;

  system.stateVersion = 4;
}
