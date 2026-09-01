{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.go-task ];
  # $XDG_CONFIG_HOME/task/taskfile.yml on recent versions, ~/.taskfile.yml on
  # older ones. Both are written.
  xdg.configFile."task/taskfile.yml".source = selfPath "home/common/go-task/config.yml";
  home.file.".taskfile.yml".source = selfPath "home/common/go-task/config.yml";
}
