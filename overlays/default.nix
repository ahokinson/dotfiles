# claude-code, codex, and opencode are plain nixpkgs packages - used directly
# as pkgs.claude-code / pkgs.codex / pkgs.opencode, not listed here.
#
# Each of the six own tools packages itself now. cerberus additionally vends
# tirith and cupcake — the two binaries it wraps onto its own PATH — so there
# is exactly one pinned copy of each here rather than a second, independently
# drifting one.
inputs: final: prev:
let
  system = final.stdenv.hostPlatform.system;

  ownTools =
    inputs.bloom.overlays.default final prev
    // inputs.cerberus.overlays.default final prev   # cerberus + tirith + cupcake
    // inputs.clipleaks.overlays.default final prev
    // inputs.pharos.overlays.default final prev
    // inputs.psyche.overlays.default final prev
    // inputs.reliquary.overlays.default final prev;
in
ownTools
// { hermes = inputs.hermes-agent.packages.${system}.default; }
// import ./open-policy-agent.nix { inherit prev; }
// import ./scorecard.nix { inherit final prev; }
// import ./semgrep.nix { inherit final; }
