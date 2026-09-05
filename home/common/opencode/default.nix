{
  selfPath,
  pkgs,
  ...
}:
let
  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };
in
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile = {
    "opencode" = {
      source = selfPath "home/common/opencode/_files";
      recursive = true;
      # tui.json gets rewritten by opencode itself on every launch, even when
      # nothing changed, unlinking home-manager's symlink. Force keeps
      # switches self-healing instead of backup-colliding with that churn.
      force = true;
    };
  } // wireShared "opencode" [
    "docs"
    "system.md"
    "SOUL.md"
  ];
}
