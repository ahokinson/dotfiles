#!/usr/bin/env zsh
# Renders the status-bar pulse: writes an animation frame to @claude_frame and
# asks tmux to redraw (tmux's own status-interval only ticks at 1s, too coarse to
# animate). Spawned once per session by tmux-state.zsh via `tmux run-shell -b`, so
# it runs under the tmux server, independent of Claude's process tree, and exits
# when @claude_pulse clears. Argument: $1 = target tmux session id.

emulate -L zsh
setopt no_unset

local session_id="${1:-}" token="${2:-}"
[[ -n "$session_id" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

local -r TAIL=200           # comet length in cells (head + fade); longer = smoother
local -r STEP=0.033         # seconds per frame (~30 fps); lower = faster animation
local -r SWEEP=28           # frames to cross the visible bar (SWEEP*STEP s); lower = faster
local -r GAP_FRACTION=0.33   # blank pause between sweeps, as a fraction of bar width (0 = none)
local -r STATUS_LEFT=1      # width of status-left (" ")
local -r LEAD_SPACE=1       # the space printed before the pulse
local -r MARGIN=2           # safety so a wide track never overflows into a wrapped line
local -r REMEASURE_EVERY=30 # recompute track width every N frames (windows/size change)

local think_color tool_color ask_color background_color
think_color=$(tmux show -gv @thm_blue 2>/dev/null) || think_color="#8caaee"
[[ -n "$think_color" ]] || think_color="#8caaee"
tool_color=$(tmux show -gv @thm_lavender 2>/dev/null) || tool_color="#babbf1"
[[ -n "$tool_color" ]] || tool_color="#babbf1"
ask_color=$(tmux show -gv @thm_yellow 2>/dev/null) || ask_color="#e5c890"
[[ -n "$ask_color" ]] || ask_color="#e5c890"
background_color=$(tmux show -gv @thm_mantle 2>/dev/null) || background_color="#292c3c"
[[ -n "$background_color" ]] || background_color="#292c3c"

# Linear hex interpolation from from_color (head) to to_color (background) in
# `length` steps, so the comet fades out smoothly rather than in coarse jumps.
build_tail() {
  local from_color=$1 to_color=$2 length=$3
  local from_red=$(( 16#${from_color:1:2} )) from_green=$(( 16#${from_color:3:2} )) from_blue=$(( 16#${from_color:5:2} ))
  local to_red=$(( 16#${to_color:1:2} )) to_green=$(( 16#${to_color:3:2} )) to_blue=$(( 16#${to_color:5:2} ))
  local index red green blue output=""
  for (( index = 0; index < length; index++ )); do
    red=$(( from_red + (to_red - from_red) * index / (length - 1) ))
    green=$(( from_green + (to_green - from_green) * index / (length - 1) ))
    blue=$(( from_blue + (to_blue - from_blue) * index / (length - 1) ))
    output+=$(printf '#%02x%02x%02x ' $red $green $blue)
  done
  print -r -- "$output"
}
local -a think_tail tool_tail ask_tail tail
think_tail=( ${(s: :)$(build_tail "$think_color" "$background_color" $TAIL)} )
tool_tail=( ${(s: :)$(build_tail "$tool_color" "$background_color" $TAIL)} )
ask_tail=( ${(s: :)$(build_tail "$ask_color" "$background_color" $TAIL)} )

# Track width = client width minus the tabs, so the pulse lands right after them.
# Each catppuccin tab renders " #I  #W " (index + name + 4 padding cells); the W:
# format iterates every window (arg1 = other, arg2 = current), so measuring it with
# a 4-char pad gives sum(4 + index + name). One tmux call fetches all three inputs.
measure_width() {
  local data client_width window_count tabs_text
  data=$(tmux display -p -t "$session_id" '#{client_width}|#{session_windows}|#{W:xxxx#{window_index}#{window_name},xxxx#{window_index}#{window_name}}' 2>/dev/null) || return 1
  client_width=${data%%|*}
  window_count=${${data#*|}%%|*}
  tabs_text=${data##*|}
  local width=$(( client_width - STATUS_LEFT - ${#tabs_text} - (window_count - 1) - LEAD_SPACE - MARGIN ))
  (( width < 10 )) && width=10
  print -r -- "$width"
}

# Position is a continuous cell offset advanced by `speed` each frame. There is no
# modulo wrap, so the tail never reappears on the left as the head exits right; it
# climbs past the right edge and through a blank gap before resetting. An absolute
# offset (speed recomputed from width) rescales smoothly if the width changes.
local state frame distance cell width pulse_and_owner
integer head=0 frame_count=0 reset_at
typeset -F head_position=0 speed=1
width=$(measure_width) || width=24
(( speed = width * 1.0 / SWEEP )); (( speed < 1 )) && speed=1
while true; do
  # One call reads the state and the current owner token. Exit if the turn ended
  # (empty state) or a newer ticker took ownership (token changed) - the latter is
  # what stops duplicates from fighting over @claude_frame.
  pulse_and_owner=$(tmux display -p -t "$session_id" '#{@claude_pulse}|#{@claude_ticker}' 2>/dev/null) || break
  state=${pulse_and_owner%%|*}
  [[ -n "$state" ]] || break
  [[ "${pulse_and_owner##*|}" == "$token" ]] || break
  case "$state" in
    tool) tail=( "${tool_tail[@]}" ) ;;
    ask)  tail=( "${ask_tail[@]}" ) ;;
    *)    tail=( "${think_tail[@]}" ) ;;
  esac

  if (( frame_count % REMEASURE_EVERY == 0 )); then
    width=$(measure_width)
    (( speed = width * 1.0 / SWEEP )); (( speed < 1 )) && speed=1
  fi
  (( head = head_position ))

  frame=""
  for (( cell = 0; cell < width; cell++ )); do
    distance=$(( head - cell ))
    if (( distance >= 0 && distance < TAIL )); then
      frame+="#[fg=${tail[distance + 1]}]█"
    else
      frame+=" "
    fi
  done
  frame+="#[default]"

  tmux set -t "$session_id" @claude_frame "$frame" ';' refresh-client -S 2>/dev/null
  (( head_position += speed ))
  (( reset_at = width + TAIL + width * GAP_FRACTION ))
  (( head_position >= reset_at )) && (( head_position = 0 ))
  (( frame_count += 1 ))
  sleep "$STEP"
done

# Only clear shared state if we still own it; a newer ticker may have taken over.
if [[ "$(tmux show -v -t "$session_id" @claude_ticker 2>/dev/null)" == "$token" ]]; then
  tmux set -u -t "$session_id" @claude_ticker 2>/dev/null
  tmux set -u -t "$session_id" @claude_frame 2>/dev/null
  tmux refresh-client -S 2>/dev/null
fi
exit 0
