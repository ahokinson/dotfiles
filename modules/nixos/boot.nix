# Bootloader only. The splash and the kernel params that quiet it are in
# splash.nix, which every importer of this module also imports.
{ lib, ... }:
{
  boot.loader.systemd-boot.enable = true;

  # mkDefault so hosts/asahi-common.nix can turn it off, as bare-metal Apple
  # Silicon requires.
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Independent of nix.gc's store cleanup (modules/nixos/settings.nix).
  boot.loader.systemd-boot.configurationLimit = 10;

  # Straight to the splash. Hold space during boot for the generation menu.
  boot.loader.timeout = 0;
}
