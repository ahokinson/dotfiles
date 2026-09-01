# Codex appends per-workspace trust_level entries to config.toml at runtime,
# so symlinking the file read-only would break trust persistence. This patches
# in the [tui] theme key instead and leaves the rest alone.
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

  # Loaded independently of config.toml; asks for one-time `/hooks` trust
  # after deployment.
  home.file.".codex/hooks.json".source = ./hooks.json;

  home.activation.codexTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${codexTheme}
  '';
}
