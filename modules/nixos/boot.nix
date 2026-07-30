# Bootloader (systemd-boot + EFI) and machine-specific kernel modules.
{ ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}