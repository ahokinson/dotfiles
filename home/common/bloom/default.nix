{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.bloom ];

  xdg.configFile."bloom" = {
    source = selfPath "home/common/bloom/_files";
    recursive = true;
  };
}
