# Codex's config.toml mixes static prefs (model, model_reasoning_effort) with
# state Codex itself appends at runtime ([projects."/path"] trust_level
# entries, written whenever a workspace is trusted in a session).
# Declaratively symlinking the whole file the way home/common/claude or
# home/common/opencode do would make it read-only and break that
# trust-persistence, so instead this only patches in the [tui] theme key -
# same read/rewrite/atomic-replace approach as zen-settings.nix's
# selfHealInstalls, which has the same "touch one field of an otherwise
# unmanaged, runtime-mutated file" shape.
{ pkgs, lib, ... }:
let
  codexTheme = pkgs.writeShellScript "codex-theme" ''
    codexConfig="$HOME/.codex/config.toml"
    mkdir -p "$(dirname "$codexConfig")"
    [[ -f "$codexConfig" ]] || : > "$codexConfig"

    ${pkgs.gawk}/bin/awk '
      /^\[tui\]/ { print; in_tui=1; seen_tui=1; next }
      /^\[/ {
        if (in_tui && !seen_theme) print "theme = \"catppuccin-frappe\""
        in_tui=0; print; next
      }
      in_tui && /^theme[ \t]*=/ { print "theme = \"catppuccin-frappe\""; seen_theme=1; next }
      { print }
      END {
        if (in_tui && !seen_theme) print "theme = \"catppuccin-frappe\""
        if (!seen_tui) { print ""; print "[tui]"; print "theme = \"catppuccin-frappe\"" }
      }
    ' "$codexConfig" > "$codexConfig.hm-tmp" && mv "$codexConfig.hm-tmp" "$codexConfig"
  '';
in
{
  home.packages = [ pkgs.codex ];

  home.activation.codexTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${codexTheme}
  '';
}
