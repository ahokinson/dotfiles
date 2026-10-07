# claude-code, codex and opencode come straight from nixpkgs, so they are not
# listed here. Each of the six own tools packages itself; cerberus also vends
# tirith and cupcake, the two binaries it wraps onto its PATH, so there is
# one pinned copy of each rather than two that can drift. busy-nas and mitos
# are the odd ones out: neither has an overlays.default of its own.
# busy-nas is reached directly by
# home/common/infrastructure/services/busy-nas/default.nix via
# inputs.busy-nas.packages.<system>.default; mitos is mapped below alongside
# hermes, so pkgs.mitos works everywhere the overlay lands.
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
  mitos = inputs.mitos.packages.${system}.default;
}
// import ./cosmic { inherit prev; }
// import ./fixes { inherit final prev; }
// import ./packages { inherit final; }
// import ./theme { inherit inputs final prev; }
