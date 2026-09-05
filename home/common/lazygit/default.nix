{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.lazygit ];
  xdg.configFile."lazygit/config.yml".source = selfPath "home/common/lazygit/config.yml";
}
