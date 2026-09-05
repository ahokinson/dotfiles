# `nh {os,darwin,home} switch` wrap the native rebuild tools with a
# nix-output-monitor tree and an nvd diff. NH_FLAKE points them at this repo,
# so none of them needs a --flake argument.
{ config, selfPath, ... }: {
  programs.nh = {
    enable = true;

    flake = import (selfPath "home/common/dotfiles-repo.nix") { inherit config; };

    # The system-level nix.gc runs as root and only reaches root's profile,
    # so without this the generations under ~/.local/state/nix/profiles
    # accumulate as GC roots forever.
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 14d";
    };
  };
}
