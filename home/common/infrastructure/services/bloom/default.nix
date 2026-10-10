{
  pkgs,
  lib,
  hostFacts,
  ...
}:
let
  agent = if hostFacts.forWork then "claude" else "opencode";
in
{
  home.packages = [ pkgs.bloom ];

  xdg.configFile."bloom/config.yml".text = lib.generators.toYAML { } {
    select = "nvim";
    tools = [
      {
        name = "zsh";
        command = "zsh";
      }
      {
        name = "lazygit";
        command = "lazygit";
      }
      {
        name = "nvim";
        command = "nvim";
      }
      {
        name = agent;
        command = agent;
      }
    ];
  };
}
