{
  selfPath,
  pkgs,
  lib,
  config,
  osConfig ? null,
  ...
}:
let
  dotfilesRepo = import (selfPath "home/common/dotfiles-repo.nix") { inherit config; };

  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };

  forWork = (import (selfPath "home/common/host.nix") { inherit osConfig; }).forWork;
  # Identical today; hand-edit settings-work.json to diverge (permission
  # mode, sandbox allowlist, etc.) the same way settings.json is hand-edited.
  settingsFile = if forWork then "settings-work.json" else "settings.json";
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
          && !(lib.hasSuffix "/_files/settings.json" path)
          && !(lib.hasSuffix "/_files/settings-work.json" path);
      };
      recursive = true;
    };

    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesRepo}/home/common/claude/_files/${settingsFile}";
  } // wireShared ".claude/plugins/marketplaces/local/plugins/custom" [
    "docs"
    "system.md"
    "SOUL.md"
  ];
}
