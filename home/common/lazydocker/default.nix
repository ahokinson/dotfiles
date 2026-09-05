{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.lazydocker ];
  xdg.configFile."lazydocker/config.yml".source = selfPath "home/common/lazydocker/config.yml";
}
