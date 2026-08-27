_: {
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
        condition = "gitdir:~/.local/src/";
      }
    ];
  };
}
