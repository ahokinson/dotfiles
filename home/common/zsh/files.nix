{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.fzf ];

  # Verbatim helpers preserved verbatim from the upstream repo
  home.file.".hushlogin".source = selfPath "home/common/zsh/_files/.hushlogin";
  home.file.".zsh/options.zsh".source = selfPath "home/common/zsh/_files/options.zsh";
  home.file.".zsh/completions.zsh".source = selfPath "home/common/zsh/_files/completions.zsh";
  home.file.".p10k.zsh".source = selfPath "home/common/zsh/_files/.p10k.zsh";
}
