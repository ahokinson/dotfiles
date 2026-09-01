# Bootloader (systemd-boot + EFI). The boot splash and the kernel params that
# quiet it live in splash.nix, which every host importing this module also
# imports. Shared by framework13 and the Asahi hosts; the one setting they
# disagree on is left overridable.
{ lib, ... }:
{
  boot.loader.systemd-boot.enable = true;

  # mkDefault so hosts/asahi-common.nix can turn it off: nixos-apple-silicon's
  # install guide calls for false on bare-metal Apple Silicon.
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Independent of nix.gc's store cleanup (modules/nixos/settings.nix).
  boot.loader.systemd-boot.configurationLimit = 10;

  # Boots straight into the splash; hold space during boot for the generation
  # menu (e.g. for a rollback).
  boot.loader.timeout = 0;
}
