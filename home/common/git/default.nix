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
    includes = [{ path = "~/.gitconfig-work"; condition = "gitdir:~/.local/src/"; }];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "catppuccin-frappe";
      syntax-theme = "Catppuccin Frappe";
      dark = true;
      line-numbers = true;
      minus-empty-line-marker-style = "normal";
      plus-empty-line-marker-style = "normal";
      "hunk-header-style" = "line-number syntax";
      "hunk-header-decoration-style" = "#8caaee ul";
      "hunk-header-file-style" = "#8caaee";
    };
  };

  # Work identity override template (user fills in ~/.gitconfig-work)
  home.file.".gitconfig-work.example".source = ./gitconfig-work.example;
}