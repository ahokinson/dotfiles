source ~/.zshrc.common

export PATH="$HOME/.local/bin:$PATH"

alias vim='nvim'

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/anders/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Hermes Agent: ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
# Added by Cupcake installer
export PATH="$HOME/.cupcake/bin:$PATH"
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
eval "$(tirith init --shell zsh)"
