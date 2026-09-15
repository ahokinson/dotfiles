{ pkgs, lib, ... }: {
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
        name = "opencode";
        command = "opencode";
      }
      {
        name = "hermes";
        command = "hermes";
      }
      {
        name = "claude";
        command = "claude";
      }
    ];
  };
}
