eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_NO_ANALYTICS=1

[[ -f "$HOME/.secrets.zsh" ]] && source "$HOME/.secrets.zsh"
