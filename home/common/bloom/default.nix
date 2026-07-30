{ pkgs, ... }: {
  home.packages = [ pkgs.bloom ];

  xdg.configFile."bloom" = {
    source = ./_files;
    recursive = true;
  };
}
