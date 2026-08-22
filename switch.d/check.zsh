# Relative-age string for a flake.lock lastModified epoch timestamp.
age_string() {
  local ts=$1 days=$(( (EPOCHSECONDS - $1) / 86400 ))
  if (( days <= 0 )); then
    print "today"
  elif (( days == 1 )); then
    print "1 day ago"
  else
    print "$days days ago"
  fi
}

# Checks one root flake input (by name + its flake.lock node key) against
# its upstream GitHub ref. Only handles type=github inputs (everything in
# this flake's root inputs is one) — anything else is reported as skipped.
check_input() {
  local name=$1 node_key=$2
  local type owner repo rev ref last_modified
  type=$(jq -r ".nodes[\"$node_key\"].locked.type // \"?\"" flake.lock)

  if [[ "$type" != github ]]; then
    printf "  %-14s (skipped — non-github input: %s)\n" "$name" "$type"
    return
  fi

  owner=$(jq -r ".nodes[\"$node_key\"].locked.owner" flake.lock)
  repo=$(jq -r ".nodes[\"$node_key\"].locked.repo" flake.lock)
  rev=$(jq -r ".nodes[\"$node_key\"].locked.rev" flake.lock)
  last_modified=$(jq -r ".nodes[\"$node_key\"].locked.lastModified" flake.lock)
  ref=$(jq -r ".nodes[\"$node_key\"].original.ref // empty" flake.lock)

  local age remote_sha
  age=$(age_string "$last_modified")
  # No ref pinned (most inputs here) means it tracks the repo's default
  # branch, which `git ls-remote`'s bare `HEAD` resolves to.
  remote_sha=$(git ls-remote "https://github.com/$owner/$repo" "${ref:-HEAD}" 2>/dev/null | awk 'NR==1{print $1}')

  if [[ -z "$remote_sha" ]]; then
    printf "  %-14s %-20s " "$name" "pinned $age"
    p "couldn't reach github — offline?" gray
  elif [[ "$remote_sha" == "$rev" ]]; then
    printf "  %-14s %-20s " "$name" "pinned $age"
    p "up to date" green
  else
    printf "  %-14s %-20s " "$name" "pinned $age"
    p "update available (${rev[1,7]} -> ${remote_sha[1,7]})" yellow
  fi
}

cmd_check() {
  if ! command -v jq &>/dev/null; then
    p "jq is required for 'check' (not found on PATH)" red
    exit 1
  fi

  pb "Flake inputs vs. upstream" yellow
  local name node_key
  jq -r '.nodes.root.inputs | to_entries[] | "\(.key)\t\(.value)"' flake.lock |
    while IFS=$'\t' read -r name node_key; do
      check_input "$name" "$node_key"
    done
}
