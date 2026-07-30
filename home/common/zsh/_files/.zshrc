if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

mkdir -p "$HOME/.cache/zsh"
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"

source $ZSH/oh-my-zsh.sh

source "$HOME/.zsh/options.zsh"
source "$HOME/.zsh/completions.zsh"

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# tirith: scan interactive commands for dangerous patterns before they run
if command -v tirith &>/dev/null; then
  eval "$(tirith init --shell zsh)"
fi

export LANG=en_US.UTF-8

export GOPATH=$HOME/.go
[[ -d "$HOME/.go/bin" ]] && export PATH=$PATH:$HOME/.go/bin

export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Disable Claude Code's defensive 256-colour clamp inside tmux (anthropics/claude-code#46146).
# Must be a shell export: the clamp runs at module load, before settings env injection.
export CLAUDE_CODE_TMUX_TRUECOLOR=1

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
