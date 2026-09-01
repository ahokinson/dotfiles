# `nh {os,darwin,home} switch` wrap the native rebuild tools with a
# nix-output-monitor tree and an nvd diff. NH_FLAKE points them at this repo,
# so none of them needs a --flake argument.
{ config, ... }: {
  programs.nh = {
    enable = true;

    # A string, not a path: must resolve to the live checkout at runtime
    # rather than being copied into the store.
    flake = "${config.home.homeDirectory}/.dotfiles";

    # The system-level nix.gc runs as root and only reaches root's profile,
    # so without this the generations under ~/.local/state/nix/profiles
    # accumulate as GC roots forever.
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 14d";
    };
  };
}
