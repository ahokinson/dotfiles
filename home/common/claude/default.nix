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
in
{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude" = {
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

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesRepo}/home/common/claude/_files/settings.json";

  home.file.".claude/plugins/marketplaces/local/plugins/custom/docs" = {
    source = selfPath "home/common/_shared/docs";
    recursive = true;
  };
  home.file.".claude/plugins/marketplaces/local/plugins/custom/system.md".source =
    selfPath "home/common/_shared/system.md";
  home.file.".claude/plugins/marketplaces/local/plugins/custom/SOUL.md".source =
    selfPath "home/common/_shared/SOUL.md";
}
