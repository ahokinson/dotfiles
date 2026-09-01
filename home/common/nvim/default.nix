{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # Keep in sync with the `parsers` list in ahokinson/nvim's
  # lua/custom/plugins/treesitter.lua. A language listed there but not here
  # falls back to nvim-treesitter's runtime install on first use.
  treesitterParserNames = [
    "bash"
    "c"
    "diff"
    "go"
    "html"
    "javascript"
    "jsdoc"
    "json"
    "lua"
    "luadoc"
    "luap"
    "markdown"
    "markdown_inline"
    "python"
    "query"
    "regex"
    "rust"
    "toml"
    "tsx"
    "typescript"
    "vim"
    "vimdoc"
    "yaml"
    "zig"
  ];
  # Each grammarPlugins.<lang> holds just parser/<lang>.so, linked in by name
  # so the result stays auditable file-by-file.
  nvimTreesitterParsers = pkgs.runCommand "nvim-treesitter-parsers" { } (
    "mkdir -p $out/parser\n"
    + lib.concatMapStrings (n: ''
      ln -s ${pkgs.vimPlugins.nvim-treesitter.grammarPlugins.${n}}/parser/${n}.so $out/parser/${n}.so
    '') treesitterParserNames
  );
in
{
  home.packages = [
    pkgs.neovim
    pkgs.tree-sitter
  ];

  # github:ahokinson/nvim, taken as a plain source tree, not a flake.
  xdg.configFile."nvim".source = inputs.nvim;

  # Pre-populates nvim-treesitter's parser dir, so it never has to compile
  # or fetch on first launch. recursive = true keeps the directory writable
  # for anything not pinned here.
  xdg.dataFile."nvim/site/parser" = {
    source = "${nvimTreesitterParsers}/parser";
    recursive = true;
  };
}
