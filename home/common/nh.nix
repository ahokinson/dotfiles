# `nh os switch` / `nh darwin switch` / `nh home switch` wrap the native
# rebuild tools, rendering the build as a nix-output-monitor tree and printing
# an nvd diff of what actually changed between generations. NH_FLAKE points
# all three at this repo, so no --flake argument is needed.
{ config, ... }: {
  programs.nh = {
    enable = true;

    # A string rather than a path: this has to resolve to the live checkout at
    # runtime instead of being copied into the store.
    flake = "${config.home.homeDirectory}/.dotfiles";

    # `nh clean user` prunes the home-manager profile. The system-level
    # nix.gc (modules/nixos/settings.nix, modules/darwin/system/settings.nix)
    # runs as root and only reaches root's own profile, so generations under
    # ~/.local/state/nix/profiles otherwise accumulate as GC roots forever.
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 14d";
    };
  };
}
