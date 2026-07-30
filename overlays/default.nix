# claude-code, codex, and opencode are plain nixpkgs packages - used directly
# as pkgs.claude-code / pkgs.codex / pkgs.opencode, not listed here.
inputs: final: prev:
inputs.flake.overlays.default final prev
