# Flake URI for the home-manager tool itself, used when running standalone
# against a non-NixOS distribution (e.g. Fedora Asahi).
readonly HOME_MANAGER_TOOL="github:nix-community/home-manager"

detect_os() {
  case "$(uname -s)" in
    Darwin) print darwin ;;
    Linux)  print linux ;;
    *)      print unknown ;;
  esac
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
