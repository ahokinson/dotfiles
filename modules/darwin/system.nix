# nix-darwin system defaults, fonts, and user account.
# Everything that targets a system-wide concern (not a user dotfile) lives here.
{ pkgs, ... }: {
  # Apple Silicon mac
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required since nix-darwin's multi-user migration: user-scoped
  # system.defaults options (dock, finder, NSGlobalDomain) apply to this user.
  system.primaryUser = "anders";

  # Use the Determinate Nix installer style (handles launchd services).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix uses GID 350 for nixbld, not nix-darwin's historical
  # default of 30000. Must match the actual group or activation aborts.
  ids.gids.nixbld = 350;

  # Fonts available to all macOS apps via the system (Nerd Fonts live in home-manager)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # macOS user defaults — feel free to extend
  system.defaults = {
    dock.autohide = true;
    dock.magnification = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };

  # Make zsh the default user shell
  programs.zsh.enable = true;

  # User account (matches ahokinson/dotfiles /Users/anders). Default shell is
  # nixpkgs-managed zsh (overrides the stock macOS zsh so it tracks nixpkgs).
  users.users."anders" = {
    name = "anders";
    home = "/Users/anders";
    shell = pkgs.zsh;
  };

  # State version for nix-darwin
  system.stateVersion = 4;
}