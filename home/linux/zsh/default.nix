{ lib, ... }: {
  programs.zsh.initContent = lib.mkAfter ''
    export PATH="$HOME/.rd/bin:$PATH"
  '';
}