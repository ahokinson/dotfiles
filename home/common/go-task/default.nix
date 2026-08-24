{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.go-task ];
  # Task global config lives at $XDG_CONFIG_HOME/task/taskfile.yml on recent versions
  # and at ~/.taskfile.yml on older ones. Both are provided for safety.
  xdg.configFile."task/taskfile.yml".source = selfPath "home/common/go-task/config.yml";
  home.file.".taskfile.yml".source = selfPath "home/common/go-task/config.yml";
}
