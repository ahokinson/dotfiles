main() {
  local mode=switch explicit=""
  while (( $# > 0 )); do
    case $1 in
      switch|build|dry) mode=$1 ;;
      list)             mode=list ;;
      check)            mode=check ;;
      -h|--help) usage; exit 0 ;;
      *)                 explicit=$1 ;;
    esac
    shift
  done

  if [[ $mode == check ]]; then
    cmd_check
    return
  fi

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
    p "Available outputs: framework13-amd-ryzen, macbookpro14-m1-pro, macstudio-m1-max, macbookpro16-m5, bookpro14-m1-pro, studio-m1-max" gray
    exit 1
  fi

  # Figure out which kind of tool to dispatch by inspecting the output name.
  local kind
  case $host in
    framework13-amd-ryzen|nixos) kind=nixos ;;
    macbookpro14-m1-pro|macstudio-m1-max|macbookpro16-m5) kind=darwin ;;
    bookpro14-m1-pro|studio-m1-max) kind=home ;;
    *) p "Unknown flake output: $host" red; exit 1 ;;
  esac

  if [[ $mode == list ]]; then
    cmd_list "$os" "$host" "$hw"
    return
  fi

  cmd_apply "$mode" "$host" "$kind"
}
