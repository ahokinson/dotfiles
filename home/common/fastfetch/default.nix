{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.fastfetch ];
  xdg.configFile."fastfetch/config.jsonc".source = selfPath "home/common/fastfetch/config.jsonc";
}
