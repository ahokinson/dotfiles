{ selfPath, osConfig ? null, ... }:
let
  forWork = (import (selfPath "home/common/host.nix") { inherit osConfig; }).forWork;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "ahokinson";
      user.email = "1762048+ahokinson@users.noreply.github.com";
      init.defaultBranch = "main";
      core.pager = "delta";
      merge.conflictstyle = "zdiff3";
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      fetch.prune = true;
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      rerere.enabled = true;
      branch.sort = "-committerdate";
      column.ui = "auto";
    };
    includes = [
      {
        path = "~/.gitconfig-work";
        # On the work Mac, every repo is presumptively a work repo; personal
        # Macs only apply it under the one directory that holds work clones.
        condition = if forWork then "gitdir:~/" else "gitdir:~/.local/src/";
      }
    ];
  };
}
