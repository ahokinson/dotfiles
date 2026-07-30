#!/usr/bin/env zsh
# switch.zsh — autodetect the host and apply the matching flake output.
#
# Usage:
#   ./switch.zsh                      Auto-detect and switch
#   ./switch.zsh switch               (same as above)
#   ./switch.zsh build                Build only (no activation)
#   ./switch.zsh dry                  Dry-run / print what would change
#   ./switch.zsh list                 Show detected host info + available outputs
#   ./switch.zsh <explicit-output>    Override auto-detection
#
# Detection strategy:
#   - Linux: read /etc/os-release (ID=nixos) + /sys/class/dmi/id/product_name,
#            or /proc/device-tree/compatible (Apple Silicon on Asahi).
#   - macOS: match the current hostname (scutil LocalHostName) against the
#            known darwin hosts. Each host config sets its own hostname, so
#            this is trivially correct once a machine has been activated at
#            least once. hw.model is cross-checked only as a sanity warning
#            (catches e.g. a hostname copied onto the wrong machine) - it is
#            NOT used to pick the output, since it's a hardcoded table that's
#            easy to get wrong without the actual hardware in hand to verify.
#   A brand-new, never-activated Mac has no matching hostname yet; pass the
#   output explicitly for that first run: `./switch.zsh switch <output>`.
#
# Modify DARWIN_HOSTS (and DARWIN_MODEL_MAP, optionally) when you add or
# rename hosts in the flake.

set -euo pipefail

zmodload zsh/datetime
autoload -U colors && colors

readonly DOTFILES=${0:A:h}
cd "$DOTFILES"

# --- ANSI helpers ---------------------------------------------------------
typeset -rA C=(
  red    1
  green  2
  yellow 3
  blue   4
  cyan   6
  gray   8
  white  7
)
p()  { print -P "%F{${C[$2]:-7}}$1%f" }
pb() { print -P "%F{${C[$2]:-7}}%B$1%b%f" }

# --- Mapping tables -------------------------------------------------------
# Known darwin flake outputs, keyed by the hostname each host config sets
# via networking.localHostName. This is the primary signal - see detect_host_darwin.
typeset -a DARWIN_HOSTS=(
  macbookpro14-m1-pro
  macbookpro16-m5
  macstudio-m1-max
)

# hw.model -> expected hostname, used only as a sanity cross-check (warns on
# mismatch, never picks the output itself). Verify any new entry with
# `sysctl -n hw.model` on the actual machine before adding it - don't guess
# (Mac Studio's entry here was wrong until checked against real hardware).
typeset -A DARWIN_MODEL_MAP=(
  "Mac13,1"         "macstudio-m1-max"
  "Mac17,2"         "macbookpro16-m5"
  "MacBookPro18,3"  "macbookpro14-m1-pro"
)

# NixOS hardware signal -> flake output. Keys are matched as a substring
# against (vendor/product/family) concatenated — order TIGHTER keys first.
# e.g. "Framework Laptop 13" matches "Framework / Laptop 13 (AMD Ryzen AI 300 Series)".
typeset -A NIXOS_HW_MAP=(
  "Framework Laptop 13"  "framework13-amd-ryzen"
)

# Asahi always maps to the shared home-manager profile, since both macs
# dual-boot it and home-manager only owns $HOME.
readonly ASAHI_OUTPUT="anders@asahi"

# Flake URI for the home-manager tool itself (used when running standalone
# against a non-NixOS distribution, e.g. Fedora Asahi). Pinned to home-manager
# master to track nixpkgs (follows our nixpkgs via the flake input already).
readonly HOME_MANAGER_TOOL="github:nix-community/home-manager"

# --- OS detection ---------------------------------------------------------
detect_os() {
  case "$(uname -s)" in
    Darwin) print darwin ;;
    Linux)  print linux ;;
    *)      print unknown ;;
  esac
}

# --- Hardware detection ---------------------------------------------------
# Print "<flake-output> <human-readable hardware id>" or exit 1.
detect_host_darwin() {
  local name
  name=$(scutil --get LocalHostName 2>/dev/null || hostname -s 2>/dev/null || true)

  if [[ -z "$name" ]] || (( ! ${DARWIN_HOSTS[(Ie)$name]} )); then
    print "" "hostname '$name'(not a known host - first activation? pass an explicit output name)"
    return 1
  fi

  # Sanity cross-check only: warn (don't fail) if hw.model disagrees with
  # what this hostname implies - could mean a hostname got copied onto the
  # wrong machine.
  local model expected
  model=$(sysctl -n hw.model 2>/dev/null || true)
  expected=${DARWIN_MODEL_MAP[$model]:-}
  if [[ -n "$expected" && "$expected" != "$name" ]]; then
    p "warning: hostname '$name' but hw.model '$model' suggests '$expected'" yellow >&2
  fi

  print "$name $name(hostname)"
}

detect_host_nixos() {
  # Concatenate DMI vendor + product + family so substring needles can match
  # any part of the hardware identity (e.g. "Framework Laptop 13" matches both
  # "Framework" (vendor) and "Laptop 13" (product) on the Framework 13).
  local vendor product family hay
  vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)
  product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
  family=$(cat /sys/class/dmi/id/product_family 2>/dev/null || true)
  hay="$vendor $product $family"

  for needle in ${(k)NIXOS_HW_MAP}; do
    if [[ "$hay" == *"$needle"* ]]; then
      print "${NIXOS_HW_MAP[$needle]} $vendor $product"
      return
    fi
  done
  print "" "$vendor / $product(unknown)"
  return 1
}

detect_host_asahi() {
  # /proc/device-tree/compatible on Apple Silicon looks like "apple,t8103\0apple,arm-platform"
  local compat
  compat=$(tr '\0' '\n' < /proc/device-tree/compatible 2>/dev/null | head -2 | tail -1)
  if [[ "$compat" == apple,* ]]; then
    print "$ASAHI_OUTPUT $compat"
  else
    print "" "(not Apple Silicon)"
    return 1
  fi
}

detect_host() {
  local os=$1
  case $os in
    darwin) detect_host_darwin ;;
    linux)
      if [[ -f /etc/os-release ]] && grep -q '^ID=nixos' /etc/os-release 2>/dev/null; then
        detect_host_nixos
      elif [[ -e /proc/device-tree/compatible ]]; then
        detect_host_asahi
      else
        print "" "(unknown Linux)"
        return 1
      fi
      ;;
    *) print "" "(unsupported OS)"; return 1 ;;
  esac
}

# --- Switch tool picker ----------------------------------------------------
# Returns the right nix tool + args for the requested mode on a given output.
build_args() {
  local mode=$1 output=$2 kind=$3
  case $kind:$mode in
    darwin:switch) print sudo darwin-rebuild switch --flake "$DOTFILES#$output" ;;
    darwin:build)  print sudo darwin-rebuild build  --flake "$DOTFILES#$output" ;;
    darwin:dry)     print sudo darwin-rebuild check  --flake "$DOTFILES#$output" ;;
    darwin:list)   return 0 ;;
    nixos:switch)  print sudo nixos-rebuild switch --flake "$DOTFILES#$output" ;;
    nixos:build)   print nixos-rebuild build      --flake "$DOTFILES#$output" ;;
    nixos:dry)     print nixos-rebuild dry-build  --flake "$DOTFILES#$output" ;;
    nixos:list)    return 0 ;;
    home:switch)   print "nix run $HOME_MANAGER_TOOL -- switch --flake \"$DOTFILES#$output\"" ;;
    home:build)    print "nix build \"$DOTFILES#homeConfigurations.\\\"$output\\\".activationPackage\"" ;;
    home:dry)      print "nix run $HOME_MANAGER_TOOL -- build --flake \"$DOTFILES#$output\"" ;;
    home:list)     return 0 ;;
    *) return 1 ;;
  esac
}

# --- Commands -------------------------------------------------------------
usage() {
  cat <<'USAGE'
switch.zsh — autodetect & apply the matching Nix flake output.

Usage: ./switch.zsh [command] [output]

Commands:
  switch   Auto-detect host and apply changes (default)
  build    Build the configuration without activating
  dry      Dry-run / print what would change
  list     Show detected host info and exit

Examples:
  ./switch.zsh                        # auto-detect + switch
  ./switch.zsh dry                    # auto-detect + dry-run
  ./switch.zsh switch macstudio-m1-max  # override auto-detection
USAGE
}

cmd_list() {
  local os=$1 host=$2 hw=$3
  pb "Detected environment" yellow
  p "  OS            : $os"      white
  p "  Hardware      : $hw"      gray
  if [[ -n "$host" ]]; then
    p "  Flake output  : $host"  green
  else
    p "  Flake output  : (could not auto-detect — pass explicitly)" red
  fi
  pb "\nAvailable flake outputs" yellow
  for o in framework13-amd-ryzen macbookpro14-m1-pro macstudio-m1-max macbookpro16-m5 anders@asahi; do
    if [[ "$o" == "$host" ]]; then
      p "  * $o" green
    else
      p "    $o" gray
    fi
  done
}

cmd_apply() {
  local mode=$1 host=$2 kind=$3
  local args
  args=$(build_args "$mode" "$host" "$kind") || {
    p "Unsupported mode/kind: $mode/$kind" red
    exit 1
  }

  # NixOS one-time setup: make /etc/nixos a symlink to this repo so future
  # bare `nixos-rebuild switch` invocations resolve to our flake. Skip in
  # dry/build modes — only switch mutates system state.
  if [[ $kind == nixos && $mode == switch ]]; then
    ensure_etc_nixos_link
  fi

  pb "Applying" cyan
  p "  Output  : $host" white
  p "  Mode    : $mode" white
  p "  Command : $args" gray
  print ""

  local start=$EPOCHREALTIME rc=0
  eval "$args" || rc=$?
  local end=$EPOCHREALTIME
  local elapsed=$(printf "%0.1f" $((end - start)))

  if (( rc == 0 )); then
    pb "OK   ${elapsed}s" green
    # nixos-rebuild writes /etc/hostname but the running kernel doesn't always
    # pick it up until reboot. Force it so `hostname` matches immediately.
    if [[ $kind == nixos && $mode == switch ]]; then
      sync_kernel_hostname "$host"
    fi
  else
    pb "FAIL (${rc}) after ${elapsed}s" red
    exit $rc
  fi
}

# Ensure /etc/nixos points at $DOTFILES. Idempotent: if already a symlink to
# the right place, no-op; if a real directory (the default NixOS layout),
# move it aside and replace with a symlink. Requires sudo.
ensure_etc_nixos_link() {
  local target=/etc/nixos
  local want="$DOTFILES"

  # Already a symlink to the right place?
  if [[ -L "$target" ]]; then
    local cur
    cur=$(readlink "$target")
    if [[ "$cur" == "$want" ]]; then
      p "  /etc/nixos -> $want (already linked)" gray
      return
    fi
    p "  /etc/nixos is a symlink to $cur (not $want) — fixing" yellow
    sudo rm -f "$target"
    sudo ln -s "$want" "$target"
    return
  fi

  # Real directory — back it up and replace.
  if [[ -e "$target" ]]; then
    local backup="${target}.old.$(date +%s)"
    p "  /etc/nixos is a real directory; backing up to $backup" yellow
    sudo mv "$target" "$backup"
  fi
  sudo ln -s "$want" "$target"
  p "  /etc/nixos -> $want" green
}

# Push the configured hostname to the running kernel.
sync_kernel_hostname() {
  local want=$1
  local have
  have=$(hostname 2>/dev/null || true)
  if [[ "$have" == "$want" ]]; then
    return
  fi
  p "  kernel hostname: '$have' -> '$want'" yellow
  sudo hostname "$want" || p "  (failed to update kernel hostname; reboot to apply)" red
}

# --- Main -----------------------------------------------------------------
main() {
  local mode=switch explicit=""
  while (( $# > 0 )); do
    case $1 in
      switch|build|dry) mode=$1 ;;
      list)             mode=list ;;
      -h|--help) usage; exit 0 ;;
      *)                 explicit=$1 ;;
    esac
    shift
  done

  local os host hw
  os=$(detect_os)

  if [[ -n "$explicit" ]]; then
    host=$explicit
    hw="(user-supplied)"
  else
    local detected
    detected=$(detect_host "$os") || true
    host=${detected%% *}
    hw=${detected#* }
  fi

  if [[ -z "$host" ]]; then
    p "Could not auto-detect host. Pass an explicit output name." red
    p "Available outputs: framework13-amd-ryzen, macbookpro14-m1-pro, macstudio-m1-max, macbookpro16-m5, anders@asahi" gray
    exit 1
  fi

  # Figure out which kind of tool to dispatch by inspecting the output name.
  local kind
  case $host in
    framework13-amd-ryzen|nixos) kind=nixos ;;
    macbookpro14-m1-pro|macstudio-m1-max|macbookpro16-m5) kind=darwin ;;
    anders@asahi|*@*) kind=home ;;
    *) p "Unknown flake output: $host" red; exit 1 ;;
  esac

  if [[ $mode == list ]]; then
    cmd_list "$os" "$host" "$hw"
    return
  fi

  cmd_apply "$mode" "$host" "$kind"
}

main "$@"