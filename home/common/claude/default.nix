{ pkgs, lib, ... }: {
  home.packages = [ pkgs.claude-code ];

  home.file.".claude" = {
    # known_marketplaces.json is Claude Code's own runtime registry of
    # installed marketplaces (absolute paths baked in, so it's inherently
    # machine-specific) — deploying it collides with the real, independently
    # -evolved copy Claude Code maintains on each machine and aborts
    # activation. Not something to declaratively manage.
    source = lib.cleanSourceWith {
      src = ./_files;
      filter = path: _type: !(lib.hasSuffix "/plugins/known_marketplaces.json" path);
    };
    recursive = true;
  };

  home.file.".claude/plugins/marketplaces/local/plugins/custom/docs" = {
    source = ../_shared/docs;
    recursive = true;
  };
  home.file.".claude/plugins/marketplaces/local/plugins/custom/system.md".source = ../_shared/system.md;
  home.file.".claude/plugins/marketplaces/local/plugins/custom/SOUL.md".source = ../_shared/SOUL.md;
}
