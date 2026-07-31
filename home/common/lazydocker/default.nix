{ selfPath, ... }: {
  xdg.configFile."lazydocker/config.yml".source = selfPath "home/common/lazydocker/config.yml";
}
