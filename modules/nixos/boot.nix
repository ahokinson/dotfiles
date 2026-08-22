# Bootloader (systemd-boot + EFI), machine-specific kernel modules, and the
# boot splash.
{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Cap boot-menu entries independently of how many generations nix.gc has
  # kept around in the store — without this, iterating quickly (or nix.gc
  # not having run yet) leaves the menu just as cluttered as before.
  boot.loader.systemd-boot.configurationLimit = 10;

  # Boot straight into the splash instead of showing the generation menu.
  # Hold space during boot to get the menu back when a rollback is needed.
  boot.loader.timeout = 0;

  # Catppuccin Frappe splash carrying the NixOS logo, replacing the scrolling
  # service log. The logo needs no asset of its own: the plymouth module's
  # `logo` option already defaults to nixos-icons' nix-snowflake-white.png and
  # links it into the catppuccin-<flavour> theme as its header image. Flavour
  # matches the rest of the machine (home/linux/catppuccin.nix).
  #
  # Set directly rather than through catppuccin/nix's own NixOS plymouth
  # module: that module is gated on a system-level `catppuccin.enable`, which
  # this repo has never set (only the home-manager side is wired up), and
  # turning it on would autoEnable the grub/sddm/tty modules alongside it.
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-frappe";
    themePackages = [ (pkgs.catppuccin-plymouth.override { variant = "frappe"; }) ];
  };

  # Silence the boot itself. Plymouth only covers the graphical splash; without
  # these the kernel and udev still write over it.
  #   quiet + loglevel=3  - kernel messages below "error"
  #   udev.log_priority   - the same for udev's own chatter
  #   rd.systemd.show_status - stops systemd printing unit status in initrd
  #   boot.shell_on_fail  - keeps a rescue shell reachable despite the above,
  #                         so a silent boot can still be debugged
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
