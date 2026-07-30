{ pkgs, ... }: {
  # Keep the upstream lazyvim-style lua verbatim under ~/.config/nvim.
  # The lazy.nvim bootstrap in init.lua fetches plugins at first launch;
  # we only install the editor + tree-sitter CLI.
  home.packages = [
    pkgs.neovim
    pkgs.tree-sitter
  ];
  xdg.configFile."nvim" = {
    source = ./_files;
    recursive = true;
  };
}