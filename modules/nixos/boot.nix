# Bootloader (systemd-boot + EFI), machine-specific kernel modules, and the
# boot splash.
{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Independent of nix.gc's store cleanup (modules/nixos/settings.nix).
  boot.loader.systemd-boot.configurationLimit = 10;

  # Boots straight into the splash; hold space during boot for the generation
  # menu (e.g. for a rollback).
  boot.loader.timeout = 0;

  # Flavour matches home/linux/catppuccin.nix. Set directly instead of
  # through catppuccin/nix's own NixOS plymouth module, which is gated on a
  # system-level catppuccin.enable this repo doesn't set.
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-frappe";
    themePackages = [ (pkgs.catppuccin-plymouth.override { variant = "frappe"; }) ];
  };

  # quiet+loglevel=3/udev.log_priority silence kernel/udev logging;
  # boot.shell_on_fail keeps a rescue shell reachable despite the silent boot.
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"
  ];

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
}
