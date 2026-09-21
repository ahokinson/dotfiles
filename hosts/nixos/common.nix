# Everything identical across the NixOS hosts. A host's own default.nix, or
# hosts/nixos/asahi/common.nix for the two Apple Silicon machines, adds only its
# hostname, hardware config, and whatever its hardware forces.
{ inputs, selfPath, ... }:
{
  imports = [
    (selfPath "modules/nixos/core")
    (selfPath "modules/nixos/desktop")
    (selfPath "modules/nixos/security")
    (selfPath "modules/nixos/programs/chromium.nix")
    (selfPath "modules/nixos/services/containers.nix")
    (selfPath "modules/nixos/services/hermes.nix")
    (selfPath "modules/nixos/user/home-manager.nix")
    (selfPath "modules/nixos/networking/networkmanager.nix")
    (selfPath "modules/nixos/services/printing.nix")
    (selfPath "modules/nixos/networking/ssh.nix")
    inputs.hermes-agent.nixosModules.default
  ];

  # Every host here was installed on this release. One first installed on a
  # later one would set its own.
  system.stateVersion = "26.05";
}
