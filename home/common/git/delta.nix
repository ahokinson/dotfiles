{ selfPath, ... }:
let
  palette = import (selfPath "home/common/palette.nix");
in
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    # Ported from catppuccin/delta's `[delta "catppuccin-frappe"]` block.
    # syntax-theme resolves against the bat theme in home/common/bat.
    options = {
      syntax-theme = "Catppuccin Frappe";
      dark = true;
      line-numbers = true;
      minus-empty-line-marker-style = "normal";
      plus-empty-line-marker-style = "normal";

      blame-palette = "${palette.base} ${palette.mantle} ${palette.crust} ${palette.surface0} ${palette.surface1}";
      commit-decoration-style = "${palette.overlay0} bold box ul";
      file-decoration-style = palette.overlay0;
      file-style = palette.text;
      line-numbers-left-style = palette.overlay0;
      line-numbers-minus-style = "bold ${palette.red}";
      line-numbers-plus-style = "bold ${palette.green}";
      line-numbers-right-style = palette.overlay0;
      line-numbers-zero-style = palette.overlay0;
      # Blended with syntax, not plain palette colors, so kept as literals.
      minus-emph-style = "bold syntax #704f5c";
      minus-style = "syntax #544452";
      plus-emph-style = "bold syntax #596b5e";
      plus-style = "syntax #475453";
      map-styles =
        "bold purple => syntax #66597e, bold blue => syntax #505d81, "
        + "bold cyan => syntax #546b7a, bold yellow => syntax #6f6860";

      # Blue underline hunk headers with no filename, overriding the base color.
      hunk-header-line-number-style = "bold ${palette.subtext0}";
      "hunk-header-style" = "line-number syntax";
      "hunk-header-decoration-style" = "${palette.blue} ul";
      "hunk-header-file-style" = palette.blue;
    };
  };
}
