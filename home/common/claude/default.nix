{
  selfPath,
  pkgs,
  lib,
  config,
  ...
}:
let
  # Not selfPath: that resolves into the store, and mkOutOfStoreSymlink below
  # needs a mutable path for Claude Code's runtime writes to settings.json to
  # survive. Assumes the checkout is at ~/.dotfiles.
  dotfilesRepo = "${config.home.homeDirectory}/.dotfiles";

  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };
in
{
  home.packages = [ pkgs.claude-code ];

  home.file = {
    ".claude" = {
      # known_marketplaces.json has absolute paths baked in and is rewritten
      # per machine, so deploying it collides with the real copy and aborts
      # activation.
      source = lib.cleanSourceWith {
        src = selfPath "home/common/claude/_files";
        filter =
          path: _type:
          !(lib.hasSuffix "/plugins/known_marketplaces.json" path)
          && !(lib.hasSuffix "/_files/settings.json" path);
      };
      recursive = true;
    };

    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesRepo}/home/common/claude/_files/settings.json";
  } // wireShared ".claude/plugins/marketplaces/local/plugins/custom" [
    "docs"
    "system.md"
    "SOUL.md"
  ];
}
