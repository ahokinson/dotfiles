# Bootloader (systemd-boot + EFI) and machine-specific kernel modules.
{ ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Cap boot-menu entries independently of how many generations nix.gc has
  # kept around in the store — without this, iterating quickly (or nix.gc
  # not having run yet) leaves the menu just as cluttered as before.
  boot.loader.systemd-boot.configurationLimit = 10;
}