# History
HISTFILE="$HOME/.cache/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS

# Safety
setopt NO_CLOBBER
setopt NO_RM_STAR_SILENT
setopt RM_STAR_WAIT

# Directory
unsetopt autocd
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
