# claude-code, codex and opencode come straight from nixpkgs, so they are not
# listed here. Each of the six own tools packages itself; cerberus also vends
# tirith and cupcake, the two binaries it wraps onto its PATH, so there is
# one pinned copy of each rather than two that can drift. busy-nas is the
# odd one out: it has no overlays.default of its own, so
# home/common/busy-nas/default.nix reaches it directly via
# inputs.busy-nas.packages.<system>.default instead.
inputs: final: prev:
let
  system = final.stdenv.hostPlatform.system;

  ownToolInputs = [
    inputs.bloom
    inputs.cerberus # cerberus + tirith + cupcake
    inputs.clipleaks
    inputs.pharos
    inputs.psyche
    inputs.reliquary
  ];
  ownTools = prev.lib.foldl' (acc: input: acc // input.overlays.default final prev) { } ownToolInputs;
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
