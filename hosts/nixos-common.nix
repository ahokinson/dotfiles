# Everything identical across the NixOS hosts. A host's own default.nix, or
# hosts/asahi-common.nix for the two Apple Silicon machines, adds only its
# hostname, hardware config, and whatever its hardware forces.
{ inputs, selfPath, ... }:
{
  imports = [
    (selfPath "modules/nixos/audio.nix")
    (selfPath "modules/nixos/boot.nix")
    (selfPath "modules/nixos/clamav.nix")
    (selfPath "modules/nixos/containers.nix")
    (selfPath "modules/nixos/desktop-cosmic.nix")
    (selfPath "modules/nixos/hermes.nix")
    (selfPath "modules/nixos/home-manager.nix")
    (selfPath "modules/nixos/locale.nix")
    (selfPath "modules/nixos/networking.nix")
    (selfPath "modules/nixos/packages.nix")
    (selfPath "modules/nixos/printing.nix")
    (selfPath "modules/nixos/security.nix")
    (selfPath "modules/nixos/settings.nix")
    (selfPath "modules/nixos/splash.nix")
    (selfPath "modules/nixos/ssh.nix")
    (selfPath "modules/nixos/user.nix")
    inputs.hermes-agent.nixosModules.default
  ];

  # Every host here was installed on this release. One first installed on a
  # later one would set its own.
  system.stateVersion = "26.05";
}
