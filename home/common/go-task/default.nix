{ pkgs, ... }: {
  home.packages = [ pkgs.go-task ];
  # Task global config lives at $XDG_CONFIG_HOME/task/taskfile.yml on recent versions
  # and at ~/.taskfile.yml on older ones — provide both for safety.
  xdg.configFile."task/taskfile.yml".source = ./config.yml;
  home.file.".taskfile.yml".source = ./config.yml;
}