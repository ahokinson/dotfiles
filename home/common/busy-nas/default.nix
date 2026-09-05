{ selfPath, ... }: {
  xdg.configFile."busy-nas/config.toml".source = selfPath "home/common/busy-nas/config.toml";
}
