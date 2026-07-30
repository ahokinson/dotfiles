{ pkgs, ... }: {
  home.packages = [ pkgs.claude-code ];

  home.file.".claude" = {
    source = ./_files;
    recursive = true;
  };

  home.file.".claude/plugins/marketplaces/local/plugins/custom/docs" = {
    source = ../_shared/docs;
    recursive = true;
  };
  home.file.".claude/plugins/marketplaces/local/plugins/custom/system.md".source = ../_shared/system.md;
  home.file.".claude/plugins/marketplaces/local/plugins/custom/SOUL.md".source = ../_shared/SOUL.md;
}
