usage() {
  cat <<'USAGE'
switch.zsh — autodetect & apply the matching Nix flake output.

Usage: ./switch.zsh [command] [output]

Commands:
  switch   Auto-detect host and apply changes (default)
  build    Build the configuration without activating
  dry      Dry-run / print what would change
  list     Show detected host info and exit
  check    Compare pinned flake inputs against upstream (no build)

Examples:
  ./switch.zsh                        # auto-detect + switch
  ./switch.zsh dry                    # auto-detect + dry-run
  ./switch.zsh switch macstudio-m1-max  # override auto-detection
  ./switch.zsh check                  # see which inputs have newer commits upstream
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
  for o in framework13-amd-ryzen macbookpro14-m1-pro macstudio-m1-max macbookpro16-m5 bookpro14-m1-pro studio-m1-max; do
    if [[ "$o" == "$host" ]]; then
      p "  * $o" green
    else
      p "    $o" gray
    fi
  done
}
