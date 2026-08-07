{ pkgs, ... }: {
  home.packages = [ pkgs.cerberus ];

  # The judgement head loads its rules from disk at runtime, and an empty
  # rules dir counts as a degraded head, which makes `cerberus gate` deny
  # every Bash call. `cerberus init` would write these, but it also rewrites
  # ~/.claude/settings.json, which home-manager deploys read-only from the
  # store. Deploying the package's own copies keeps the rules in lockstep
  # with the binary and skips the imperative step entirely.
  #
  # No config.toml is deployed: cerberus treats a missing one as "all heads
  # enabled", which is what we want anyway.
  home.file.".config/cerberus/rules".source = "${pkgs.cerberus}/share/cerberus/rules";
}
