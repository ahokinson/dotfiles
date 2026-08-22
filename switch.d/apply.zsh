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
    # nixos-rebuild writes /etc/hostname but the running kernel doesn't
    # always pick it up until reboot. Force it so `hostname` matches
    # immediately.
    if [[ $kind == nixos && $mode == switch ]]; then
      sync_kernel_hostname "$host"
    fi
    if [[ $kind == home && $mode == switch && -n "$ASAHI_TARGET_HOSTNAME" ]]; then
      sync_asahi_hostname "$ASAHI_TARGET_HOSTNAME"
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

# Asahi has no nix layer to own the system hostname (home-manager only owns
# $HOME), so this sets it directly - persistently, via hostnamectl, since
# Fedora expects that rather than the transient `hostname` command.
sync_asahi_hostname() {
  local want=$1
  local have
  have=$(hostname 2>/dev/null || true)
  if [[ "$have" == "$want" ]]; then
    return
  fi
  p "  hostname: '$have' -> '$want'" yellow
  sudo hostnamectl set-hostname "$want" || p "  (failed to update hostname)" red
}
