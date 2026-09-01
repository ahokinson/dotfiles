# claude-code, codex and opencode come straight from nixpkgs, so they are not
# listed here. Each of the six own tools packages itself; cerberus also vends
# tirith and cupcake, the two binaries it wraps onto its PATH, so there is
# one pinned copy of each rather than two that can drift.
inputs: final: prev:
let
  system = final.stdenv.hostPlatform.system;

  ownTools =
    inputs.bloom.overlays.default final prev
    // inputs.cerberus.overlays.default final prev # cerberus + tirith + cupcake
    // inputs.clipleaks.overlays.default final prev
    // inputs.pharos.overlays.default final prev
    // inputs.psyche.overlays.default final prev
    // inputs.reliquary.overlays.default final prev;
in
ownTools
// {
  hermes = inputs.hermes-agent.packages.${system}.default;
}
// import ./cosmic-applets.nix { inherit prev; }
// import ./open-policy-agent.nix { inherit prev; }
// import ./scorecard.nix { inherit final prev; }
// import ./semgrep.nix { inherit final; }
// import ./signal.nix {
  inherit inputs final prev;
  inherit (final) lib;
}
