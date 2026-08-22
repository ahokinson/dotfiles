# Known darwin flake outputs, keyed by the hostname each host config sets
# via networking.localHostName — the primary signal (see detect_host_darwin).
typeset -a DARWIN_HOSTS=(
  macbookpro14-m1-pro
  macbookpro16-m5
  macstudio-m1-max
)

# hw.model -> expected hostname, used only as a sanity cross-check (warns on
# mismatch, never picks the output itself). Verify any new entry with
# `sysctl -n hw.model` on the actual machine before adding it - don't guess.
typeset -A DARWIN_MODEL_MAP=(
  "Mac13,1"         "macstudio-m1-max"
  "Mac17,2"         "macbookpro16-m5"
  "MacBookPro18,3"  "macbookpro14-m1-pro"
)

# Print "<flake-output> <human-readable hardware id>" or exit 1.
detect_host_darwin() {
  local name
  name=$(scutil --get LocalHostName 2>/dev/null || hostname -s 2>/dev/null || true)

  if [[ -z "$name" ]] || (( ! ${DARWIN_HOSTS[(Ie)$name]} )); then
    print "" "hostname '$name'(not a known host - first activation? pass an explicit output name)"
    return 1
  fi

  local model expected
  model=$(sysctl -n hw.model 2>/dev/null || true)
  expected=${DARWIN_MODEL_MAP[$model]:-}
  if [[ -n "$expected" && "$expected" != "$name" ]]; then
    p "warning: hostname '$name' but hw.model '$model' suggests '$expected'" yellow >&2
  fi

  print "$name $name(hostname)"
}
