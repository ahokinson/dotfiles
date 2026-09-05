{ selfPath, ... }: {
  xdg.configFile."lazygit/config.yml".source = selfPath "home/common/lazygit/config.yml";
}
