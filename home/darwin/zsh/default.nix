{ lib, ... }:
let
  files = ./.;
in {
  programs.zsh.initContent = lib.mkAfter ''
    export PATH="$HOME/.local/bin:$PATH"

    alias vim='nvim'

    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    # bun completions
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  '';

  home.file.".zprofile".source = "${files}/.zprofile";
  home.file.".secrets.zsh".source = "${files}/.secrets.zsh";
  home.file.".zsh/manage-secret" = {
    source = "${files}/manage-secret";
    executable = true;
  };
}