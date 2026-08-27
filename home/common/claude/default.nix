{
  selfPath,
  pkgs,
  lib,
  config,
  ...
}:
let
  # Real on-disk checkout path - deliberately NOT selfPath. selfPath
  # resolves into the immutable Nix store copy of the flake; this needs a
  # mutable path outside the store so mkOutOfStoreSymlink lets Claude
  # Code's own runtime writes to settings.json survive rebuilds. Assumes
  # the repo is checked out at ~/.dotfiles.
  dotfilesRepo = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude" = {
    # known_marketplaces.json is Claude Code's own runtime registry of
    # installed marketplaces. Absolute paths are baked in, so it's
    # machine-specific. Deploying it collides with the real copy Claude Code
    # maintains on each machine and aborts activation - not something to
    # manage declaratively.
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
