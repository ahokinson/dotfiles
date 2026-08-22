# claude-code, codex, and opencode are plain nixpkgs packages - used directly
# as pkgs.claude-code / pkgs.codex / pkgs.opencode, not listed here.
inputs: final: prev:
let
  flakePkgs = inputs.flake.overlays.default final prev;
in
flakePkgs
// import ./open-policy-agent.nix { inherit prev; }
// import ./psyche.nix { inherit final flakePkgs; }
// import ./scorecard.nix { inherit final prev; }
// import ./semgrep.nix { inherit final; }
