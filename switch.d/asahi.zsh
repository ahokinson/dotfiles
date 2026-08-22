# Device-tree codename (first entry of /proc/device-tree/compatible) -> the
# short per-machine hostname to use on Asahi (see flake.nix's
# homeConfigurations - never "asahi" itself). Verify any new entry with
# `tr '\0' '\n' < /proc/device-tree/compatible` on the actual Asahi boot
# before adding it - don't guess.
typeset -A ASAHI_HW_MAP=(
  "apple,j314s"  "bookpro14-m1-pro"
  # TODO: Mac Studio's codename unverified - boot Asahi on it, run
  # `tr '\0' '\n' < /proc/device-tree/compatible | head -1`, and add:
  # "apple,XXXX"  "studio-m1-max"
)

# Set as a side effect of detect_host_asahi; consumed by cmd_apply to sync
# the system hostname after a switch.
typeset -g ASAHI_TARGET_HOSTNAME=""

detect_host_asahi() {
  local codename hostname_target
  codename=$(tr '\0' '\n' < /proc/device-tree/compatible 2>/dev/null | head -1)
  if [[ "$codename" != apple,* ]]; then
    print "" "(not Apple Silicon)"
    return 1
  fi

  hostname_target=${ASAHI_HW_MAP[$codename]:-}
  if [[ -z "$hostname_target" ]]; then
    print "" "codename '$codename'(unrecognized Asahi machine - add it to ASAHI_HW_MAP)"
    return 1
  fi

  ASAHI_TARGET_HOSTNAME=$hostname_target
  print "$hostname_target $hostname_target($codename)"
}
