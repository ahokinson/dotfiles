# hermes-agent local NixOS service — driven by the hermes-agent flake input
# wired through overlays/default.nix (so the binary is `pkgs.hermes-agent`).
{ ... }: {
  services.hermes-agent.enable = true;
}