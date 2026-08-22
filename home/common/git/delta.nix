{ ... }: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    # Catppuccin Frappe inlined (ported from catppuccin/delta's
    # `[delta "catppuccin-frappe"]` block) so it applies on every platform;
    # `syntax-theme` resolves against the bat theme in home/common/bat.
    options = {
      syntax-theme = "Catppuccin Frappe";
      dark = true;
      line-numbers = true;
      minus-empty-line-marker-style = "normal";
      plus-empty-line-marker-style = "normal";

      blame-palette = "#303446 #292c3c #232634 #414559 #51576d";
      commit-decoration-style = "#737994 bold box ul";
      file-decoration-style = "#737994";
      file-style = "#c6d0f5";
      line-numbers-left-style = "#737994";
      line-numbers-minus-style = "bold #e78284";
      line-numbers-plus-style = "bold #a6d189";
      line-numbers-right-style = "#737994";
      line-numbers-zero-style = "#737994";
      minus-emph-style = "bold syntax #704f5c";
      minus-style = "syntax #544452";
      plus-emph-style = "bold syntax #596b5e";
      plus-style = "syntax #475453";
      map-styles =
        "bold purple => syntax #66597e, bold blue => syntax #505d81, "
        + "bold cyan => syntax #546b7a, bold yellow => syntax #6f6860";

      # Blue underline hunk headers with no filename, overriding the Frappe base.
      hunk-header-line-number-style = "bold #a5adce";
      "hunk-header-style" = "line-number syntax";
      "hunk-header-decoration-style" = "#8caaee ul";
      "hunk-header-file-style" = "#8caaee";
    };
  };
}
