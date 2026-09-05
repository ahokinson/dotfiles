{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.k9s ];
  xdg.configFile."k9s/config.yaml".source = selfPath "home/common/k9s/config.yaml";
  xdg.configFile."k9s/plugins.yaml".source = selfPath "home/common/k9s/plugins.yaml";
  xdg.configFile."k9s/skins/catppuccin-mocha.yaml".source =
    selfPath "home/common/k9s/skins/catppuccin-mocha.yaml";
}
