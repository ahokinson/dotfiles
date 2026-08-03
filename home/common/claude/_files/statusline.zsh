#!/usr/bin/env zsh
# Claude Code statusline: two width-aware rows of coloured words, no powerline.
# Parses the session JSON on stdin and mines the transcript for what the JSON
# can't give (tool histogram, context burn-down, token spend). Lowest-priority
# fields drop first when a row can't fit the terminal width.
# See README.md and https://code.claude.com/docs/en/statusline.
emulate -L zsh
setopt no_nomatch no_unset pipe_fail extended_glob 2>/dev/null || true
zmodload zsh/datetime 2>/dev/null || true
: ${EPOCHSECONDS:=$(date +%s)}

raw_json="$(cat)"

# stdin JSON -> assoc array (schema below is the contract with Claude Code).
local -A session
while IFS=$'\t' read -r key value; do session[$key]="$value"; done < <(
  print -r -- "$raw_json" | jq -r '
    { model:      (.model.display_name // "?"),
      effort:     (.effort.level // ""),
      thinking:   (.thinking.enabled // false),
      fast:       (.fast_mode // false),
      pct:        (.context_window.used_percentage // 0 | floor),
      ctxsize:    (.context_window.context_window_size // 200000),
      cost:       (.cost.total_cost_usd // 0),
      added:      (.cost.total_lines_added // 0),
      removed:    (.cost.total_lines_removed // 0),
      rl5:        (.rate_limits.five_hour.used_percentage // ""),
      rl5_reset:  (.rate_limits.five_hour.resets_at // ""),
      rl7:        (.rate_limits.seven_day.used_percentage // ""),
      rl7_reset:  (.rate_limits.seven_day.resets_at // ""),
      transcript: (.transcript_path // ""),
      session_id: (.session_id // "nosession")
    } | to_entries[] | "\(.key)\t\(.value)"'
)

local session_id="${session[session_id]}"
local mining_state_file="${TMPDIR:-/tmp}/cc-statusline-${session_id}.state"

# Per-session guard violation counts, written by guard-tirith.zsh / guard-cupcake.zsh
# / guard-context.zsh on each deny (guard/violations-<sid>.state: tirith=N cupcake=N
# context=N).
integer tirith=0 cupcake=0 context=0
local violations_file="${XDG_STATE_HOME:-$HOME/.local/state}/guard/violations-${session_id}.state"
[[ -r "$violations_file" ]] && source "$violations_file" 2>/dev/null

# Incrementally mine only the NEW transcript lines. State persists as sourceable
# zsh assignments (mined_lines, tokens_in, tokens_out, tool_counts, ctx_samples)
# so we re-jq nothing we've already seen.
integer mined_lines=0 tokens_in=0 tokens_out=0
local -A tool_counts
local -a ctx_samples
[[ -r "$mining_state_file" ]] && source "$mining_state_file" 2>/dev/null

local transcript="${session[transcript]}"
if [[ -n "$transcript" && -r "$transcript" ]]; then
  integer line_count
  line_count=$(wc -l < "$transcript" 2>/dev/null) || line_count=0
  if (( line_count > mined_lines )); then
    new_lines="$(tail -n "+$((mined_lines + 1))" "$transcript" 2>/dev/null)"
    # drop a trailing partial (not newline-terminated) line; wc -l already excluded it
    [[ -n "$(tail -c1 "$transcript" 2>/dev/null)" ]] && new_lines="${new_lines%$'\n'*}"
    if [[ -n "$new_lines" ]]; then
      # one jq over the new bytes -> event tokens: T=tool use, C=context size
      # (for the sparkline), U=tokens fed up (input + cache), D=tokens generated.
      while IFS=$'\t' read -r event value; do
        case "$event" in
          T) (( tool_counts[$value]++ )) ;;
          C) ctx_samples+=("$value") ;;
          U) (( tokens_in += value )) ;;
          D) (( tokens_out += value )) ;;
        esac
      done < <(print -r -- "$new_lines" | jq -Rr '
        fromjson? as $l | $l
        | if (.type=="assistant") then
            ( .message.usage as $u
              | if $u then
                  "C\t\((($u.input_tokens//0)+($u.cache_creation_input_tokens//0)+($u.cache_read_input_tokens//0)))",
                  "U\t\((($u.input_tokens//0)+($u.cache_creation_input_tokens//0)+($u.cache_read_input_tokens//0)))",
                  "D\t\(($u.output_tokens//0))"
                else empty end ),
            ( .message.content[]? | select(.type=="tool_use") | "T\t" + .name )
          else empty end')
    fi
    mined_lines=$line_count
    (( ${#ctx_samples} > 40 )) && ctx_samples=("${ctx_samples[@]: -40}")
  fi
fi

{
  print -r -- "mined_lines=$mined_lines"
  print -r -- "tokens_in=$tokens_in"
  print -r -- "tokens_out=$tokens_out"
  typeset -p tool_counts
  typeset -p ctx_samples
} > "$mining_state_file" 2>/dev/null

# Catppuccin Frappe palette, mirroring config/common/zsh/.p10k.zsh. Each entry is
# a ready-to-emit truecolor escape (fg + "R;G;B" + m), so field strings read like
# coloured markup. The R;G;B stays quoted so the semicolons are literal bytes.
local fg=$'\e[38;2;'
local ROSEWATER="${fg}242;213;207m" FLAMINGO="${fg}238;190;190m" PINK="${fg}244;184;228m"
local MAUVE="${fg}202;158;230m" RED="${fg}231;130;132m" MAROON="${fg}234;153;156m"
local PEACH="${fg}239;159;118m" YELLOW="${fg}229;200;144m" GREEN="${fg}166;209;137m"
local TEAL="${fg}129;200;190m" SKY="${fg}153;209;233m" SAPPHIRE="${fg}133;193;220m"
local BLUE="${fg}140;170;238m" LAVENDER="${fg}186;187;241m"
local TEXT="${fg}198;208;245m" SUBTEXT1="${fg}181;191;226m" SUBTEXT0="${fg}165;173;206m"
local OVERLAY2="${fg}148;156;187m" OVERLAY1="${fg}131;139;167m" OVERLAY0="${fg}115;121;148m"
local SURFACE2="${fg}98;104;128m" SURFACE1="${fg}81;87;109m" SURFACE0="${fg}65;69;89m"
local BASE="${fg}48;52;70m" MANTLE="${fg}41;44;60m" CRUST="${fg}35;38;52m"
local RESET=$'\e[0m'

# Per-character truecolor gradient between two palette colours, interpolated in
# HSL so the hue sweeps and the midtones stay saturated (RGB interpolation greys
# them out). The helpers set their results in the caller's scope (zsh dynamic
# scoping) to avoid a subshell per character.
_rgb2hsl() { # $1 r $2 g $3 b (0-255) -> caller hue/sat/lum (0..1)
  local -F r=$(( $1 / 255.0 )) g=$(( $2 / 255.0 )) b=$(( $3 / 255.0 )) max min d
  max=$(( r > g ? (r > b ? r : b) : (g > b ? g : b) ))
  min=$(( r < g ? (r < b ? r : b) : (g < b ? g : b) ))
  d=$(( max - min )); lum=$(( (max + min) / 2 ))
  if (( d == 0 )); then hue=0; sat=0; return; fi
  sat=$(( lum > 0.5 ? d / (2 - max - min) : d / (max + min) ))
  if   (( max == r )); then hue=$(( (g - b) / d + (g < b ? 6 : 0) ))
  elif (( max == g )); then hue=$(( (b - r) / d + 2 ))
  else                      hue=$(( (r - g) / d + 4 )); fi
  hue=$(( hue / 6 ))
}
_hue2channel() { # $1 p $2 q $3 t -> caller channel (0..1)
  local -F p=$1 q=$2 t=$3
  (( t < 0 )) && (( t += 1 )); (( t > 1 )) && (( t -= 1 ))
  if   (( t < 1.0/6 )); then channel=$(( p + (q - p) * 6 * t ))
  elif (( t < 1.0/2 )); then channel=$q
  elif (( t < 2.0/3 )); then channel=$(( p + (q - p) * (2.0/3 - t) * 6 ))
  else                       channel=$p; fi
}
_hsl2rgb() { # $1 h $2 s $3 l (0..1) -> caller r g b (0-255)
  local -F h=$1 s=$2 l=$3 q p channel
  if (( s == 0 )); then (( r = l * 255 + 0.5 )); g=$r; b=$r; return; fi
  q=$(( l < 0.5 ? l * (1 + s) : l + s - l * s )); p=$(( 2 * l - q ))
  _hue2channel $p $q $(( h + 1.0/3 )); (( r = channel * 255 + 0.5 ))
  _hue2channel $p $q $h;               (( g = channel * 255 + 0.5 ))
  _hue2channel $p $q $(( h - 1.0/3 )); (( b = channel * 255 + 0.5 ))
}
# Endpoint hues/sat/lum plus the hue delta swept the shorter way round the
# wheel, shared by gradient() and lerp_color() (caller-scope out params).
_hue_delta() { # $1 start colour $2 end colour -> caller h1 s1 l1 h2 s2 l2 dh
  local -a start=(${(s:;:)${${1#"$fg"}%m}}) end=(${(s:;:)${${2#"$fg"}%m}})
  local -F hue sat lum
  _rgb2hsl $start[1] $start[2] $start[3]; h1=$hue; s1=$sat; l1=$lum
  _rgb2hsl $end[1]   $end[2]   $end[3];   h2=$hue; s2=$sat; l2=$lum
  dh=$(( h2 - h1 ))
  (( dh > 0.5 )) && (( dh -= 1 )); (( dh < -0.5 )) && (( dh += 1 ))
}
gradient() { # $1 = text, $2 = start colour, $3 = end colour; opt $4 = offset, $5 = span
  local text="$1"
  local -F h1 s1 l1 h2 s2 l2 dh
  _hue_delta "$2" "$3"
  integer n=${#text} i r g b
  integer off=${4:-0} span=${5:-$n}       # colour text as chars [off, off+n) of a span-wide sweep
  local -F t h
  local out=""
  for (( i = 1; i <= n; i++ )); do
    t=$(( span > 1 ? (off + i - 1.0) / (span - 1) : 0 ))
    h=$(( h1 + dh * t )); (( h < 0 )) && (( h += 1 )); (( h >= 1 )) && (( h -= 1 ))
    _hsl2rgb $h $(( s1 + (s2 - s1) * t )) $(( l1 + (l2 - l1) * t ))
    out+="${fg}${r};${g};${b}m${text[i]}"
  done
  print -rn -- "$out"
}
# A single colour interpolated at fraction t (0..1) from start to end, taking the
# shorter way round the hue wheel (same maths as gradient(), one point not a sweep).
# Colours a value by magnitude, e.g. a usage % on a green->red ramp.
lerp_color() { # $1 = t (0..1)  $2 = start escape  $3 = end escape  -> REPLY = colour escape
  local -F t=$1; (( t < 0 )) && t=0; (( t > 1 )) && t=1
  local -F h1 s1 l1 h2 s2 l2 dh
  _hue_delta "$2" "$3"
  local -F h=$(( h1 + dh * t )); (( h < 0 )) && (( h += 1 )); (( h >= 1 )) && (( h -= 1 ))
  integer r g b
  _hsl2rgb $h $(( s1 + (s2 - s1) * t )) $(( l1 + (l2 - l1) * t ))
  REPLY="${fg}${r};${g};${b}m"
}

# 8-level block glyphs (the only surviving glyph set) for the context sparkline.
local ticks=$'▁▂▃▄▅▆▇█'

# Each field carries its (fully self-coloured) text, a target row, and a drop
# priority. Rows are fit to COLUMNS independently.
local -a field_line field_text field_priority
push() { field_line+=("$1"); field_text+=("$2"); field_priority+=("$3") }

# Field drop priorities: when a row is too narrow, its lowest-numbered droppable
# field goes first, so the drop order is DIFF, TOKENS, COST, TOOLS, RATE,
# CONTEXT. PINNED (100) is never dropped. Priorities are row-independent.
integer PRI_PINNED=100 PRI_CONTEXT=50 PRI_RATE=45 PRI_TOOLS=40 \
        PRI_COST=30 PRI_TOKENS=25 PRI_DIFF=10

# Visible width = the field minus its colour escapes -> caller REPLY.
visible_width() { local stripped=${(S)1//$'\e'\[[0-9;]#m/}; REPLY=${#stripped} }
# Right-pad a (coloured) field to a fixed visible width, so an absent or shorter
# field still holds its column and nothing downstream shifts. The bar is never
# width-tight here, so we never truncate; over-long content just overflows.
pad_field() { # $1 = content (may be empty)  $2 = slot width
  visible_width "$1"; integer gap=$(( $2 - REPLY )); (( gap < 0 )) && gap=0
  print -rn -- "$1"; printf '%*s' $gap ''
}
# Fixed slot widths (visible chars) for the intermittent fields. Tune freely.
integer W_DIFF=7 W_TOOLS=15 W_COST=6 W_TOKENS=13

integer turns=${#ctx_samples}
integer ctx_size=${session[ctxsize]:-200000}
integer i

# ─── Row 1: what the session did ─────────────────────────────────────────────

# Lines added / removed, straight from the JSON. Always shown; each side is
# lowlit while its count is 0, bright once it has moved (mirrors guard_cell).
integer added=${session[added]:-0} removed=${session[removed]:-0}
local add_fg=$OVERLAY2 rem_fg=$OVERLAY2
(( added   > 0 )) && add_fg=$GREEN
(( removed > 0 )) && rem_fg=$RED
local diff_text="${add_fg}+${added} ${rem_fg}-${removed}"
push 1 "$(pad_field "$diff_text" $W_DIFF)" $PRI_DIFF

# Tool histogram: fold tools into named buckets, then show all seven categories
# as "glyph N" at all times (including the ones still at 0), always in the same
# fixed order so each icon keeps its place. Glyphs are Nerd Font (Font Awesome)
# private-use codepoints.
local -A bucket
local tool_name
for tool_name in ${(k)tool_counts}; do
  case "$tool_name" in
    (Edit|Write|MultiEdit|NotebookEdit) (( bucket[edits]+=tool_counts[$tool_name] )) ;;
    (Read)                              (( bucket[reads]+=tool_counts[$tool_name] )) ;;
    (Bash)                              (( bucket[runs]+=tool_counts[$tool_name] )) ;;
    (Grep|Glob)                         (( bucket[searches]+=tool_counts[$tool_name] )) ;;
    (Task|Agent)                        (( bucket[agents]+=tool_counts[$tool_name] )) ;;
    (WebFetch|WebSearch)                (( bucket[web]+=tool_counts[$tool_name] )) ;;
    (*)                                 (( bucket[other]+=tool_counts[$tool_name] )) ;;
  esac
done
local -A glyph=(
    edits    $''   # fa-pencil
    reads    $''   # fa-book
    runs     $''   # fa-terminal
    searches $''   # fa-search
    agents   $''   # fa-user
    web      $''   # fa-globe
    other    $''   # fa-puzzle-piece
)
# Always rendered in this fixed order, so each icon keeps its place run to run.
local -a categories=(agents reads searches web edits runs other)
local tools_text="" label
for label in $categories; do
  tools_text+="${tools_text:+ }${TEXT}${glyph[$label]} ${SUBTEXT0}${bucket[$label]:-0}"
done
push 1 "$(pad_field "$tools_text" $W_TOOLS)" $PRI_TOOLS

# resets_at is an ISO8601 UTC string (a bare epoch is also accepted).
countdown() { # $1 = ISO8601 (UTC) or epoch -> REPLY = "Nd" / "Nh" / "Nm" / "now" / ""
  REPLY=""
  local -i target
  if [[ $1 == <-> ]]; then
    target=$1
  else
    # Normalize to bare local wall-time (values are UTC via TZ=UTC below): drop a
    # trailing Z or numeric offset (±HH:MM / ±HHMM), then fractional seconds.
    local iso=${1%%[-+]<->:<->}; iso=${iso%%[-+]<->}; iso=${iso%Z}; iso=${iso%%.*}
    target=$(TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%S' "$iso" +%s 2>/dev/null) \
      || target=$(TZ=UTC date -d "$1" +%s 2>/dev/null) || return
  fi
  local -i remaining=$(( target - EPOCHSECONDS ))
  (( remaining <= 0 ))     && { REPLY="now"; return }
  (( remaining >= 86400 )) && { REPLY="$(( remaining/86400 ))d"; return }
  (( remaining >= 3600 ))  && { REPLY="$(( remaining/3600 ))h"; return }
  REPLY="$(( remaining/60 ))m"
}

# Session spend, coloured on a traffic-light ramp by dollar amount (same idea as
# the rate-limit severity below): calm when cheap, hotter as it climbs. On a
# Claude.ai plan (Pro/Max) the figure is an estimate you aren't billed per
# session, so it's muted instead. The statusline JSON only sends rate_limits to
# subscribers, so their presence is our "on a plan" signal.
integer on_plan=0
[[ -n "${session[rl5]}" || -n "${session[rl7]}" ]] && on_plan=1
cost_fg() { # $1 = cost (float USD) -> REPLY = palette colour
  (( on_plan )) && { REPLY="$OVERLAY2"; return }
  if   (( $1 >= 15 )); then REPLY="$RED"
  elif (( $1 >= 5 ));  then REPLY="$PEACH"
  elif (( $1 >= 1 ));  then REPLY="$YELLOW"
  else                      REPLY="$GREEN"; fi
}
local -F cost=${session[cost]:-0}
local cost_text=""
if (( cost > 0.01 )); then
  cost_fg $cost
  cost_text="${REPLY}$(printf '$%.2f' $cost)"
fi
push 1 "$(pad_field "$cost_text" $W_COST)" $PRI_COST

# Cumulative token spend, split by direction: in (fed to the model) / out (generated).
humanize() { # $1 = integer -> REPLY = "1.2M" / "1M" / "34k" / "789"
  if   (( $1 >= 1000000 )); then local m=$(printf '%.1f' $(( $1 / 1000000.0 ))); REPLY="${m%.0}M"
  elif (( $1 >= 1000 ));    then REPLY="$(( $1 / 1000 ))k"
  else                           REPLY="$1"; fi
}
local tokens_text=""
if (( tokens_in > 0 || tokens_out > 0 )); then
  humanize $tokens_in;  local in_str="$REPLY"
  humanize $tokens_out; local out_str="$REPLY"
  # one gradient sweep spanning both numbers; the white arrows break it in two.
  integer tokens_span=$(( ${#in_str} + ${#out_str} ))
  tokens_text="${TEXT}↑ $(gradient "$in_str" "$MAUVE" "$SKY" 0 $tokens_span)"
  tokens_text+="${TEXT} ↓ $(gradient "$out_str" "$MAUVE" "$SKY" ${#in_str} $tokens_span)"
fi
push 1 "$(pad_field "$tokens_text" $W_TOKENS)" $PRI_TOKENS

# Context: pct + a sparkline of recent fill + a trend word for its slope. The
# sparkline autoscales to the window's own min..max, so it shows the SHAPE of
# context growth/compaction regardless of how small a slice of a big context
# window is in use (a fixed fraction-of-window scale pins to the floor on a 1M
# window). Trend is measured in absolute tokens/turn so it reacts the same on any
# window size (1000/turn matches the sensitivity of the old 0.5%-of-200k slope).
local sparkline=""
if (( turns >= 2 )); then
  integer window=8
  (( turns < window )) && window=$turns
  integer lo=${ctx_samples[turns]} hi=${ctx_samples[turns]} level
  for (( i = turns - window + 1; i <= turns; i++ )); do
    (( ctx_samples[i] < lo )) && lo=${ctx_samples[i]}
    (( ctx_samples[i] > hi )) && hi=${ctx_samples[i]}
  done
  integer span=$(( hi - lo ))
  for (( i = turns - window + 1; i <= turns; i++ )); do
    (( span > 0 )) && level=$(( (ctx_samples[i] - lo) * 7 / span + 1 )) || level=1
    sparkline+="${ticks[$level]}"
  done
fi
local trend=""
if (( turns >= 4 )); then
  integer slope=$(( (ctx_samples[-1] - ctx_samples[-4]) / 3 ))   # tokens per turn
  if   (( slope >  1000 )); then trend="rising"
  elif (( slope < -1000 )); then trend="falling"
  else                           trend="steady"; fi
fi
# PEACH when rising (pain), GREEN when falling (relief), OVERLAY2 when steady.
local trend_fg="$OVERLAY2"
[[ "$trend" == "rising" ]]  && trend_fg="$PEACH"
[[ "$trend" == "falling" ]] && trend_fg="$GREEN"
# pct% and the sparkline share one TEAL->GREEN sweep, starting at the percent.
local pct_str="${session[pct]}%" context_text
if [[ -n "$sparkline" ]]; then
  integer chart_span=$(( ${#pct_str} + ${#sparkline} ))
  context_text="$(gradient "$pct_str" "$TEAL" "$GREEN" 0 $chart_span)"
  context_text+=" $(gradient "$sparkline" "$TEAL" "$GREEN" ${#pct_str} $chart_span)"
else
  context_text="${TEAL}${pct_str}"
fi
humanize $ctx_size; context_text+="${TEXT} of $REPLY"
[[ -n "$trend" ]] && context_text+="${trend_fg} $trend"
push 1 "$context_text" $PRI_CONTEXT

# ─── Row 2: where the session stands ─────────────────────────────────────────

# Guards. The shield carries health (see below); the two deny counts after it
# are tirith then cupcake, each coloured by how much its denials matter: tirith
# blocks are serious -> RED, cupcake blocks are worth noting -> PEACH, both muted
# while the count is 0. A guard that isn't running shows a dim "-" instead of a
# count, so "off" never reads as "0 denies". tirith needs its binary on PATH;
# cupcake also needs opa + the stub policies; both share the degraded sentinel
# (mirrors guard-health.zsh). Never dropped.
local degraded_sentinel="${XDG_STATE_HOME:-$HOME/.local/state}/guard/degraded"
local cupcake_stub="${XDG_DATA_HOME:-$HOME/.local/share}/cupcake-stub/.cupcake/policies/claude"
local context_hook="${HOME}/.claude/hooks/guard-context.zsh"
# state = absent (binary not on PATH) | degraded (sentinel set, or a required dep
# missing) | healthy. Extra args are requirements for healthy: a /-prefixed arg
# must exist as a path, anything else must be a command on PATH.
guard_state() { # $1 = guard binary  $2.. = extra requirements  -> REPLY
  command -v "$1" >/dev/null 2>&1 || { REPLY=absent; return }
  [[ -f "$degraded_sentinel" ]]   && { REPLY=degraded; return }
  local dep
  for dep in "${@:2}"; do
    if [[ $dep == /* ]]; then [[ -e "$dep" ]]                     || { REPLY=degraded; return }
    else                      command -v "$dep" >/dev/null 2>&1   || { REPLY=degraded; return }
    fi
  done
  REPLY=healthy
}
local tirith_state cupcake_state context_state
guard_state tirith;                        tirith_state="$REPLY"
guard_state cupcake opa "$cupcake_stub";   cupcake_state="$REPLY"
guard_state git "$context_hook" jq;        context_state="$REPLY"
# state + count -> caller guard_fg + guard_cell: a not-running guard shows a dim
# "-"; otherwise the deny count, in the guard's severity colour once it has fired
# and muted while still 0.
guard_cell() { # $1 = state  $2 = deny count  $3 = severity colour
  if [[ "$1" == absent ]]; then guard_fg="$SURFACE2"; guard_cell="-"; return; fi
  guard_cell="$2"
  (( $2 > 0 )) && guard_fg="$3" || guard_fg="$OVERLAY2"
}
local guard_fg guard_cell
guard_cell "$tirith_state"  "$tirith"  "$RED";    local tirith_fg="$guard_fg"  tirith_cell="$guard_cell"
guard_cell "$cupcake_state" "$cupcake" "$PEACH";  local cupcake_fg="$guard_fg" cupcake_cell="$guard_cell"
guard_cell "$context_state" "$context" "$YELLOW"; local context_fg="$guard_fg" context_cell="$guard_cell"
# Per-guard icons, shown just before each deny count (Nerd Font private-use).
local context_glyph=$'\uf06e'   # nf-fa-eye (change codepoint to taste)
local tirith_glyph=$'\uf286' cupcake_glyph=$'\uf1fd'
local shield=$'\uf132'   # fa-shield
# Shield = the guards' worst state: RED if any is degraded, else PEACH if any is
# missing, else GREEN.
local shield_fg="$GREEN"
[[ "$tirith_state" == absent   || "$cupcake_state" == absent   || "$context_state" == absent   ]] && shield_fg="$PEACH"
[[ "$tirith_state" == degraded || "$cupcake_state" == degraded || "$context_state" == degraded ]] && shield_fg="$RED"
push 2 "${shield_fg}${shield} ${tirith_fg}${tirith_glyph} ${tirith_cell} ${cupcake_fg}${cupcake_glyph} ${cupcake_cell} ${context_fg}${context_glyph} ${context_cell}" $PRI_PINNED

# Model name + live modifiers (effort, thinking, fast), swept in one gradient.
local model_text="${session[model]}"
[[ -n "${session[effort]}" ]]        && model_text+=" ${session[effort]}"
[[ "${session[thinking]}" == true ]] && model_text+=" thinking"
[[ "${session[fast]}" == true ]]     && model_text+=" fast"
push 2 "$(gradient "$model_text" "$MAUVE" "$SKY")" $PRI_PINNED

# Rate limits: both windows always shown as "<pct>% of <window> resets <countdown>"
# (echoing the context row's "of 1000k" phrasing). Colour does the talking: the pct
# rides a continuous green->red ramp by how much of the window is used (green when
# fresh, hot as it fills). Below 80% the "of <window>" phrase and the "resets <when>"
# phrase carry two distinct muted tones so the two facts read apart; at >=80% the
# WHOLE segment adopts the pct's (by then hot) colour so a limit you're about to hit
# lights up. resets_at is a bare epoch or ISO string.
local mid_dot=$'·'
rate_fg() { # $1 = pct-int -> REPLY = colour on a green->red usage ramp
  lerp_color $(( $1 / 100.0 )) "$GREEN" "$RED"
}
rate_segment() { # $1 = pct-int  $2 = window-label  $3 = reset stamp (may be empty)
  local -i p=$1
  rate_fg $p; local col="$REPLY"
  local win="$OVERLAY0" rst="$OVERLAY2"           # "of <window>" darker, "resets <when>" normal
  (( p >= 80 )) && { win="$col"; rst="$col"; }     # warning lights the whole segment
  local seg="${col}${p}%${win} of $2"
  if [[ -n "$3" ]]; then countdown "$3"; [[ -n "$REPLY" ]] && seg+="${rst} resets $REPLY"; fi
  print -rn -- "$seg"
}
local rate_text=""
if [[ -n "${session[rl5]}" ]]; then
  rate_text=$(rate_segment "${session[rl5]%.*}" "5h" "${session[rl5_reset]}")
fi
if [[ -n "${session[rl7]}" ]]; then
  rate_text="${rate_text:+$rate_text  ${OVERLAY2}${mid_dot}  }$(rate_segment "${session[rl7]%.*}" "7d" "${session[rl7_reset]}")"
fi
[[ -n "$rate_text" ]] && push 2 "$rate_text" $PRI_RATE

# ─── Render ──────────────────────────────────────────────────────────────────
# Each row is composed and width-fit independently, so a narrow terminal drops
# the lowest-priority fields per row rather than across the whole bar.
integer field_count=${#field_text}
local -a field_active
for (( i=1; i<=field_count; i++ )); do field_active[i]=1; done

compose_row() { # $1 = row number
  local row="" first=1 j
  for (( j=1; j<=field_count; j++ )); do
    (( field_active[j] )) || continue
    [[ "${field_line[j]}" == "$1" ]] || continue
    (( first )) && row+=" " || row+="  "
    row+="${field_text[j]}"
    first=0
  done
  print -rn -- "${row}${RESET}"
}

# Drop the lowest-priority droppable field on a row until it fits.
fit_row() { # $1 = row number, $2 = cols
  local row="$1" cols="$2"
  local rendered=$(compose_row "$row")
  visible_width "$rendered"
  while (( REPLY > cols )); do
    integer lowest=0 j
    for (( j=1; j<=field_count; j++ )); do
      (( field_active[j] && field_priority[j] < PRI_PINNED )) || continue
      [[ "${field_line[j]}" == "$row" ]] || continue
      (( lowest == 0 || field_priority[j] < field_priority[lowest] )) && lowest=$j
    done
    (( lowest == 0 )) && break
    field_active[lowest]=0
    rendered=$(compose_row "$row")
    visible_width "$rendered"
  done
  print -rn -- "$rendered"
}

integer cols=${COLUMNS:-80}
local row1 row2
row1=$(fit_row 1 "$cols")
row2=$(fit_row 2 "$cols")
print -r -- "$row1"
print -rn -- "$row2"
