_: {
  # opencode reads its config from $XDG_CONFIG_HOME/opencode/.
  # The upstream tree ships opencode.json, themes/, and plugin/ — copy verbatim.
  xdg.configFile."opencode" = {
    source = ./_files;
    recursive = true;
  };
}