# claude-code, codex and opencode come straight from nixpkgs, so they are not
# listed here. Each of the six own tools packages itself; cerberus also vends
# tirith and cupcake, the two binaries it wraps onto its PATH, so there is
# one pinned copy of each rather than two that can drift. busy-nas is the
# odd one out: it has no overlays.default of its own, so
# home/common/infrastructure/services/busy-nas/default.nix reaches it directly via
# inputs.busy-nas.packages.<system>.default instead.
#
# Everything below own tools/hermes is grouped by what kind of override it
# is, not which package it touches: cosmic (pop-os desktop-shell behavior
# patches), fixes (workarounds for a broken nixpkgs derivation), packages
# (a whole package nixpkgs doesn't have), theme (a reskin of an otherwise
# unthemed app).
inputs: final: prev:
let
  system = final.stdenv.hostPlatform.system;

  ownToolInputs = [
    inputs.bloom
    inputs.cerberus # cerberus + tirith + cupcake
    inputs.clipleaks
    inputs.lifesaver
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
// import ./cosmic { inherit prev; }
// import ./fixes { inherit final prev; }
// import ./packages { inherit final; }
// import ./theme { inherit inputs final prev; }
