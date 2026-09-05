{ selfPath, ... }:
let
  palette = import (selfPath "home/common/palette.nix");
  themeName = import (selfPath "home/common/bat/theme-name.nix");
in
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    # Ported from catppuccin/delta's `[delta "catppuccin-mocha"]` block.
    # syntax-theme resolves against the bat theme in home/common/bat.
    options = {
      syntax-theme = themeName;
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
      minus-emph-style = "bold syntax #694559";
      minus-style = "syntax #493447";
      plus-emph-style = "bold syntax #4e6356";
      plus-style = "syntax #394545";
      map-styles =
        "bold purple => syntax #5b4e74, bold blue => syntax #445375, "
        + "bold cyan => syntax #446170, bold yellow => syntax #6b635b";

      # Blue underline hunk headers with no filename, overriding the base color.
      hunk-header-line-number-style = "bold ${palette.subtext0}";
      "hunk-header-style" = "line-number syntax";
      "hunk-header-decoration-style" = "${palette.blue} ul";
      "hunk-header-file-style" = palette.blue;
    };
  };
}
