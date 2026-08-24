# PLACEHOLDER. Not a real generated hardware config. Unlike
# framework13-amd-ryzen's (produced by nixos-generate-config on that
# machine), this file can't be authored sight-unseen: it needs the actual
# filesystem/UUIDs/kernel-modules layout from the real bare-metal install.
#
# Replace this file with the one produced during the hands-on install, per
# nixos-apple-silicon's docs/uefi-standalone.md guide: bootstrap a UEFI
# environment via the Asahi installer, build/boot the NixOS installer ISO
# (`nix build .#installer-bootstrap` in that project's flake), partition and
# install, then copy the generated hardware-configuration.nix here.
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];
  fileSystems = { };
  swapDevices = [ ];
}
