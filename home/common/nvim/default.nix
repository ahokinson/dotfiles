{ inputs, pkgs, lib, ... }:
let
  # Keep in sync with the `parsers` list in ahokinson/nvim's
  # lua/custom/plugins/treesitter.lua. Any language added there but not here
  # just falls back to nvim-treesitter's own runtime install (via the
  # tree-sitter CLI + gcc below) on first use.
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
  # Each grammarPlugins.<lang> derivation contains just parser/<lang>.so;
  # link them in explicitly by name rather than merging the derivations
  # wholesale, so the result is easy to audit file-by-file.
  nvimTreesitterParsers = pkgs.runCommand "nvim-treesitter-parsers" { } (
    "mkdir -p $out/parser\n"
    + lib.concatMapStrings (n: ''
      ln -s ${pkgs.vimPlugins.nvim-treesitter.grammarPlugins.${n}}/parser/${n}.so $out/parser/${n}.so
    '') treesitterParserNames
  );
in {
  home.packages = [
    pkgs.neovim
    pkgs.tree-sitter
  ];

  # Config now lives at github:ahokinson/nvim (flake.nix's nvim input,
  # fetched as a plain source tree - not a flake itself).
  xdg.configFile."nvim".source = inputs.nvim;

  # Pre-populate nvim-treesitter's parser dir so the pinned languages are
  # already "installed" the moment this generation activates, instead of
  # nvim-treesitter compiling/fetching them (and erroring) on first launch.
  # recursive = true keeps the directory itself writable so nvim-treesitter
  # can still install anything not covered here.
  xdg.dataFile."nvim/site/parser" = {
    source = "${nvimTreesitterParsers}/parser";
    recursive = true;
  };
}
