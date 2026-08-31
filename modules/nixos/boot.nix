# Bootloader (systemd-boot + EFI) and machine-specific kernel modules. The
# boot splash and the kernel params that quiet it live in splash.nix, which
# the Asahi hosts import without this module.
_: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Independent of nix.gc's store cleanup (modules/nixos/settings.nix).
  boot.loader.systemd-boot.configurationLimit = 10;

  # Boots straight into the splash; hold space during boot for the generation
  # menu (e.g. for a rollback).
  boot.loader.timeout = 0;
}
