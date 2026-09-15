# Codex appends per-workspace trust_level entries to config.toml at runtime,
# so symlinking the file read-only would break trust persistence. This patches
# in the top-level model/effort keys and the [tui] theme key instead and
# leaves the rest alone.
{
  pkgs,
  lib,
  selfPath,
  osConfig ? null,
  ...
}:
let
  inherit ((import (selfPath "home/common/lib/host.nix") { inherit osConfig; })) forWork;
  # Identical today; diverge model/effort here (e.g. a work-provisioned
  # account) the same way home/common/development/source-control/git/config.nix diverges git identity.
  modelSettings = {
    personal = {
      model = "gpt-5.6-terra";
      effort = "xhigh";
    };
    work = {
      model = "gpt-5.6-terra";
      effort = "xhigh";
    };
  };
  inherit (if forWork then modelSettings.work else modelSettings.personal) model effort;

  codexConfig = pkgs.writeShellScript "codex-config" ''
    codexConfig="$HOME/.codex/config.toml"
    mkdir -p "$(dirname "$codexConfig")"
    [[ -f "$codexConfig" ]] || : > "$codexConfig"

    ${pkgs.gawk}/bin/awk '
      BEGIN { before_section = 1 }
      /^\[/ && before_section {
        if (!seen_model) print "model = \"${model}\""
        if (!seen_effort) print "model_reasoning_effort = \"${effort}\""
        before_section = 0
      }
      /^\[tui\]/ { print; in_tui=1; seen_tui=1; next }
      /^\[/ {
        if (in_tui && !seen_theme) print "theme = \"catppuccin-mocha\""
        in_tui=0; print; next
      }
      before_section && /^model[ \t]*=/ { print "model = \"${model}\""; seen_model=1; next }
      before_section && /^model_reasoning_effort[ \t]*=/ { print "model_reasoning_effort = \"${effort}\""; seen_effort=1; next }
      in_tui && /^theme[ \t]*=/ { print "theme = \"catppuccin-mocha\""; seen_theme=1; next }
      { print }
      END {
        if (before_section) {
          if (!seen_model) print "model = \"${model}\""
          if (!seen_effort) print "model_reasoning_effort = \"${effort}\""
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
  home.file.".codex/hooks.json".text = builtins.toJSON {
    description = "Render Codex activity and session metrics through pharos in tmux.";
    hooks = {
      SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=codex";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch tool --tool=codex";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch think --tool=codex";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
            }
          ];
        }
      ];
      PermissionRequest = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch ask --tool=codex";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch think --tool=codex";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
            }
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=codex";
            }
          ];
        }
      ];
      SessionEnd = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux render --tool=codex";
              timeout = 3;
            }
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=codex";
              timeout = 3;
            }
          ];
        }
      ];
    };
  };

  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${codexConfig}
  '';
}
