'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  autoload -Uz is-at-least && is-at-least 5.1 || return

  local -A CATPPUCCIN_MOCHA=(
    rosewater 224
    flamingo  224
    pink      218
    mauve     183
    red       211
    maroon    181
    peach     216
    yellow    223
    green     151
    teal      116
    sky       116
    sapphire  117
    blue      111
    lavender  147
    text      189
    subtext1  146
    subtext0  146
    overlay2  103
    overlay1  103
    overlay0  243
    surface2  241
    surface1  239
    surface0  237
    base      235
    mantle    234
    crust     233
  )

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\u2502'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\u2502'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%${CATPPUCCIN_MOCHA[overlay0]}F╭─"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%${CATPPUCCIN_MOCHA[overlay0]}F├─"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%${CATPPUCCIN_MOCHA[overlay0]}F╰─"
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX="%${CATPPUCCIN_MOCHA[overlay0]}F─╮"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX="%${CATPPUCCIN_MOCHA[overlay0]}F─┤"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX="%${CATPPUCCIN_MOCHA[overlay0]}F─╯"
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=$CATPPUCCIN_MOCHA[overlay0]
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$CATPPUCCIN_MOCHA[base]
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$CATPPUCCIN_MOCHA[text]

  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$CATPPUCCIN_MOCHA[blue]
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$CATPPUCCIN_MOCHA[text]
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$CATPPUCCIN_MOCHA[subtext1]
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$CATPPUCCIN_MOCHA[text]
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  local anchor_files=(
    .git
    .shorten_folder_marker
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$CATPPUCCIN_MOCHA[peach]
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$CATPPUCCIN_MOCHA[peach]
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$CATPPUCCIN_MOCHA[peach]
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$CATPPUCCIN_MOCHA[peach]
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$CATPPUCCIN_MOCHA[surface2]
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    typeset -g my_git_format="%${CATPPUCCIN_MOCHA[base]}F${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}"
  }
  functions -M my_git_formatter 2>/dev/null

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
