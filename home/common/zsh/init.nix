# Powerlevel10k's instant prompt must come first in .zshrc, hence mkBefore,
# which home-manager promotes above the fpath loop and the oh-my-zsh block.
# The per-platform overlays use mkAfter and land below it.
{ lib, selfPath, ... }:
let
  palette = import (selfPath "home/common/palette.nix");
in
{
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore ''
      # Set before oh-my-zsh sources itself, or its termsupport.zsh writes
      # the window title on every prompt, ignoring ghostty's own setting.
      DISABLE_AUTO_TITLE="true"

      # Powerlevel10k instant prompt. Keep near the top of .zshrc.
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
        # Inline rather than the catppuccin module's fzf port, which needs
        # programs.fzf.enable. bg/bg+ omitted to keep terminal transparency.
        export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
          --color=fg:${palette.text},fg+:${palette.text},bg:${palette.base},bg+:${palette.surface0} \
          --color=hl:${palette.mauve},hl+:${palette.lavender} \
          --color=info:${palette.overlay1},prompt:${palette.mauve},pointer:${palette.rosewater} \
          --color=marker:${palette.green},spinner:${palette.sky},header:${palette.overlay1} \
          --color=border:${palette.surface0},gutter:${palette.mantle},separator:${palette.surface0}"
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
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
    ''
  ];
}
