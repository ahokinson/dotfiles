# Codex appends per-workspace trust_level entries to config.toml at runtime,
# so symlinking the file read-only would break trust persistence. This patches
# in the top-level model/effort keys and the [tui] theme key instead and
# leaves the rest alone.
{ pkgs, lib, ... }:
let
  codexConfig = pkgs.writeShellScript "codex-config" ''
    codexConfig="$HOME/.codex/config.toml"
    mkdir -p "$(dirname "$codexConfig")"
    [[ -f "$codexConfig" ]] || : > "$codexConfig"

    ${pkgs.gawk}/bin/awk '
      BEGIN { before_section = 1 }
      /^\[/ && before_section {
        if (!seen_model) print "model = \"gpt-5.6-terra\""
        if (!seen_effort) print "model_reasoning_effort = \"xhigh\""
        before_section = 0
      }
      /^\[tui\]/ { print; in_tui=1; seen_tui=1; next }
      /^\[/ {
        if (in_tui && !seen_theme) print "theme = \"catppuccin-mocha\""
        in_tui=0; print; next
      }
      before_section && /^model[ \t]*=/ { print "model = \"gpt-5.6-terra\""; seen_model=1; next }
      before_section && /^model_reasoning_effort[ \t]*=/ { print "model_reasoning_effort = \"xhigh\""; seen_effort=1; next }
      in_tui && /^theme[ \t]*=/ { print "theme = \"catppuccin-mocha\""; seen_theme=1; next }
      { print }
      END {
        if (before_section) {
          if (!seen_model) print "model = \"gpt-5.6-terra\""
          if (!seen_effort) print "model_reasoning_effort = \"xhigh\""
        }
        if (in_tui && !seen_theme) print "theme = \"catppuccin-mocha\""
        if (!seen_tui) { print ""; print "[tui]"; print "theme = \"catppuccin-mocha\"" }
      }
    ' "$codexConfig" > "$codexConfig.hm-tmp" && mv "$codexConfig.hm-tmp" "$codexConfig"
  '';
in
{
  home.packages = [ pkgs.codex ];

  # Loaded independently of config.toml; asks for one-time `/hooks` trust
  # after deployment.
  home.file.".codex/hooks.json".source = ./hooks.json;

  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${codexConfig}
  '';
}
