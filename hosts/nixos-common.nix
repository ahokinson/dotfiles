# Shared by every NixOS host (framework13-amd-ryzen, bookpro14-m1-pro,
# studio-m1-max): the modular system config and home-manager wiring that is
# byte-for-byte identical between them. A host's own default.nix - or
# hosts/asahi-common.nix, which sits between this and the two Apple Silicon
# machines - supplies only its hostname, its hardware-configuration.nix, and
# whatever its hardware genuinely forces.
#
# Counterpart to hosts/darwin-common.nix, which does the same job for the Macs.
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

  # Every NixOS host here was installed on the same release, the way
  # modules/darwin/system/settings.nix carries one system.stateVersion for
  # every Mac. A host first installed on a later release would set its own.
  system.stateVersion = "26.05";
}
