# Everything shared by the two headless Raspberry Pi 4 appliances (pi-hole
# and pi-nas). Deliberately does not import hosts/nixos-common.nix: that
# pulls in a full COSMIC desktop, a hardcoded personal printer, on-access AV
# scanning, pipewire, and the plymouth boot splash - none of it applies to a
# headless box with no display and no login session. Each host's own
# default.nix adds only its hostname, fileSystems (or disko-config.nix for
# pi-nas's extra SSD), and the one service it exists to run.
{
  inputs,
  selfPath,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    (selfPath "modules/nixos/containers.nix")
    (selfPath "modules/nixos/locale.nix")
    (selfPath "modules/nixos/networking.nix")
    (selfPath "modules/nixos/packages.nix")
    (selfPath "modules/nixos/security.nix")
    (selfPath "modules/nixos/settings.nix")
    (selfPath "modules/nixos/ssh.nix")
    (selfPath "modules/nixos/user.nix")
  ];

  # No modules/nixos/boot.nix: that's systemd-boot/EFI, which a Pi 4 doesn't
  # have - raspberry-pi-4.base owns boot.loader.raspberry-pi instead.
  # No modules/nixos/home-manager.nix: single-purpose appliances, never
  # logged into interactively, so no home-manager profile of any kind.
  # No hermes.nix, audio.nix, clamav.nix, desktop-cosmic.nix, printing.nix,
  # splash.nix: agent/desktop/display-oriented, out of scope for these two
  # minimal boxes by design.

  # modules/nixos/printing.nix is the only other place avahi lives in this
  # repo, and it isn't imported here - without this, the installer's
  # temporary rpi4-installer.local name would stop resolving the moment the
  # real config activates, since networking.hostName's own pi-hole.local/
  # pi-nas.local would have nothing publishing it. Same shape as
  # printing.nix's own block, minus the printer-sharing context.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # No console ever reaches these boxes - management is 100% over SSH, which
  # is already the real access gate (key-only, per modules/nixos/ssh.nix).
  # A sudo password prompt only protects against someone physically at a
  # keyboard, which doesn't apply here, and it silently breaks
  # `nixos-rebuild switch --target-host anders@<ip> --use-remote-sudo` (the
  # only way to update these hosts, since root login is disabled) unless
  # anders has a password to type at that exact moment - a needless trap
  # for a box no one is sitting in front of.
  security.sudo.wheelNeedsPassword = false;

  # presentDevicePolicy "allow" in modules/nixos/security.nix assumes
  # someone can reach a console to run `usbguard allow-device` for anything
  # plugged in after boot - true for the laptop-theft threat model it was
  # written for, not for a box with no monitor or keyboard ever attached.
  # Blocking pi-nas's own SSD after a reboot, with no way to unblock it
  # short of reflashing, is worse than the threat it defends against here.
  services.usbguard.enable = lib.mkForce false;

  # Four cores on a Pi 4, against the sixteen threads modules/nixos/
  # settings.nix sizes its mkDefault caps for. Half-the-machine policy,
  # rescaled again as hosts/asahi-common.nix does for its ten-core pair - a
  # nix-daemon rebuild should never compete with the DNS resolver or Samba
  # daemon this box exists to serve.
  nix.settings.cores = 2;
  systemd.services.nix-daemon.serviceConfig.CPUQuota = "200%";

  system.stateVersion = "26.05";
}
