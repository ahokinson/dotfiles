# Powerlevel10k instant prompt must be the very first thing in .zshrc, so it
# goes into initContent with lib.mkBefore (HM promotes mkBefore content to
# the head of .zshrc, ahead of the NIX_PROFILES fpath loop and the oh-my-zsh
# sourcing block). linux/darwin host overlays append via lib.mkAfter and
# land after the OMZ block (mkAfter > default priority > mkBefore).
{ lib, ... }: {
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore ''
      # Must be set before oh-my-zsh sources itself: its termsupport.zsh
      # otherwise sets the window title on every prompt/command via its own
      # escape sequences, independent of ghostty's own
      # shell-integration-features title setting.
      DISABLE_AUTO_TITLE="true"

      # Powerlevel10k instant prompt. Should stay near the top of .zshrc.
      if [[ -r "''${XDG_CONFIG_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CONFIG_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '')
    ''
      ZSH_AUTOSUGGEST_STRATEGY=(history)

      export XDG_CONFIG_HOME="$HOME/.config"
      export GOPATH=$HOME/.go
      [[ -d "$HOME/.go/bin" ]] && export PATH=$PATH:$HOME/.go/bin
      export K9S_CONFIG_DIR="$HOME/.config/k9s"
      export LANG=en_US.UTF-8
      export CLAUDE_CODE_TMUX_TRUECOLOR=1

      mkdir -p "$HOME/.cache/zsh"
      export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"

      source "$HOME/.zsh/options.zsh"
      source "$HOME/.zsh/completions.zsh"

      if command -v fzf &>/dev/null; then
        source <(fzf --zsh)
        # Catppuccin Frappe palette for fzf (inline so it stays decoupled
        # from the catppuccin HM module's fzf port, which requires
        # programs.fzf.enable = true). Honors transparent terminal
        # backgrounds by omitting bg/bg+.
        export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
          --color=fg:#c6d0f5,fg+:#c6d0f5,bg:#303446,bg+:#414559 \
          --color=hl:#ca9ee6,hl+:#babbf1 \
          --color=info:#838ba7,prompt:#ca9ee6,pointer:#f2d5cf \
          --color=marker:#a6d189,spinner:#99d1db,header:#838ba7 \
          --color=border:#414559,gutter:#292c3c,separator:#414559"
      fi

      if command -v tirith &>/dev/null; then
        eval "$(tirith init --shell zsh)"
      fi

      if command -v reliquary &>/dev/null; then
        eval "$(reliquary hook zsh)"
      fi

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    ''
    ''
      # bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
    ''
  ];
}
