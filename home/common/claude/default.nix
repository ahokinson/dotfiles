{ selfPath, pkgs, lib, config, ... }: {
  home.packages = [ pkgs.claude-code ];

  home.file.".claude" = {
    # known_marketplaces.json is Claude Code's own runtime registry of
    # installed marketplaces. Absolute paths are baked in, so it's
    # machine-specific. Deploying it collides with the real copy Claude Code
    # maintains on each machine and aborts activation - not something to
    # manage declaratively.
    source = lib.cleanSourceWith {
      src = selfPath "home/common/claude/_files";
      filter = path: _type:
        !(lib.hasSuffix "/plugins/known_marketplaces.json" path)
        && !(lib.hasSuffix "/_files/settings.json" path);
    };
    recursive = true;
  };

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home/common/claude/_files/settings.json";

  home.file.".claude/plugins/marketplaces/local/plugins/custom/docs" = {
    source = selfPath "home/common/_shared/docs";
    recursive = true;
  };
  home.file.".claude/plugins/marketplaces/local/plugins/custom/system.md".source = selfPath "home/common/_shared/system.md";
  home.file.".claude/plugins/marketplaces/local/plugins/custom/SOUL.md".source = selfPath "home/common/_shared/SOUL.md";
}
