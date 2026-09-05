{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.btop ];
  xdg.configFile."btop/btop.conf".source = selfPath "home/common/btop/btop.conf";
  xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
    selfPath "home/common/btop/themes/catppuccin_mocha.theme";
}
