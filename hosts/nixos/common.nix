# Everything identical across the NixOS hosts. A host's own default.nix, or
# hosts/nixos/asahi/common.nix for the two Apple Silicon machines, adds only its
# hostname, hardware config, and whatever its hardware forces.
{ inputs, selfPath, ... }:
{
  imports = [
    (selfPath "modules/nixos/core/audio.nix")
    (selfPath "modules/nixos/core/boot.nix")
    (selfPath "modules/nixos/programs/chromium.nix")
    (selfPath "modules/nixos/security/clamav.nix")
    (selfPath "modules/nixos/services/containers.nix")
    (selfPath "modules/nixos/desktop/cosmic.nix")
    (selfPath "modules/nixos/desktop/sway.nix")
    (selfPath "modules/nixos/services/hermes.nix")
    (selfPath "modules/nixos/user/home-manager.nix")
    (selfPath "modules/nixos/core/locale.nix")
    (selfPath "modules/nixos/networking/networkmanager.nix")
    (selfPath "modules/nixos/core/packages.nix")
    (selfPath "modules/nixos/services/printing.nix")
    (selfPath "modules/nixos/security/usbguard.nix")
    (selfPath "modules/nixos/core/settings.nix")
    (selfPath "modules/nixos/desktop/splash.nix")
    (selfPath "modules/nixos/networking/ssh.nix")
    (selfPath "modules/nixos/core/user.nix")
    inputs.hermes-agent.nixosModules.default
  ];

  # Every host here was installed on this release. One first installed on a
  # later one would set its own.
  system.stateVersion = "26.05";
}
