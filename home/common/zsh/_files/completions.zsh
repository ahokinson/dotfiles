# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Arrow-key menu selection
zstyle ':completion:*' menu select

# Cache expensive completions (docker, kubectl, etc.)
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/completion-cache"
