{
  selfPath,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };

  forWork = (import (selfPath "home/common/host.nix") { inherit osConfig; }).forWork;
  # Identical today; hand-edit opencode-work.json to diverge (model/provider,
  # permission mode, etc.) the same way opencode.json is hand-edited.
  configFile = if forWork then "opencode-work.json" else "opencode.json";
in
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile = {
    "opencode" = {
      source = lib.cleanSourceWith {
        src = selfPath "home/common/opencode/_files";
        filter =
          path: _type:
          !(lib.hasSuffix "/_files/opencode.json" path) && !(lib.hasSuffix "/_files/opencode-work.json" path);
      };
      recursive = true;
      # tui.json gets rewritten by opencode itself on every launch, even when
      # nothing changed, unlinking home-manager's symlink. Force keeps
      # switches self-healing instead of backup-colliding with that churn.
      force = true;
    };

    "opencode/opencode.json" = {
      source = selfPath "home/common/opencode/_files/${configFile}";
      force = true;
    };
  } // wireShared "opencode" [
    "docs"
    "system.md"
    "SOUL.md"
  ];
}
