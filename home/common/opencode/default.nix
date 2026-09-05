{
  selfPath,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode" = {
    source = selfPath "home/common/opencode/_files";
    recursive = true;
    # tui.json gets rewritten by opencode itself on every launch, even when
    # nothing changed, unlinking home-manager's symlink. Force keeps
    # switches self-healing instead of backup-colliding with that churn.
    force = true;
  };

  xdg.configFile."opencode/docs" = {
    source = selfPath "home/common/_shared/docs";
    recursive = true;
  };
  xdg.configFile."opencode/system.md".source = selfPath "home/common/_shared/system.md";
  xdg.configFile."opencode/SOUL.md".source = selfPath "home/common/_shared/SOUL.md";
}
