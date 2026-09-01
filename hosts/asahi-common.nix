# Shared by every Asahi NixOS host (bookpro14-m1-pro, studio-m1-max): the
# Apple-Silicon-specific overrides on top of hosts/nixos-common.nix, which
# carries everything these share with framework13-amd-ryzen. Each host's own
# default.nix supplies just its hostname and hardware-config import.
{ inputs, selfPath, ... }:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    (selfPath "hosts/nixos-common.nix")
  ];

  hardware.asahi.enable = true;

  # Rebuilds on these hosts need --impure, permanently - this is not a TODO.
  # hardware.asahi.peripheralFirmwareDirectory defaults to a findFirst over
  # `builtins.pathExists /boot/vendorfw/firmware.cpio`, an absolute path that
  # pure eval refuses to read. Setting it to a /nix/store path does not help
  # either, since pure eval rejects those too. The only way to make it pure
  # would be to carry firmware.cpio inside the flake, and it is non-free and
  # non-redistributable, so that is off the table for this repo.
  # .github/workflows/check.yml neutralises just that option so CI can still
  # type-check the rest of these hosts.

  # Broadcom Wi-Fi on Apple Silicon needs iwd, per nixos-apple-silicon's docs
  # (NetworkManager's default wpa_supplicant backend isn't supported here).
  networking.networkmanager.wifi.backend = "iwd";

  # The one thing these hosts take differently from modules/nixos/boot.nix,
  # imported via nixos-common: nixos-apple-silicon's own install guide calls
  # for false where that module defaults to true. A plain definition beats its
  # mkDefault.
  boot.loader.efi.canTouchEfiVariables = false;

  # modules/nixos/settings.nix sizes its build caps for framework13's sixteen
  # threads and leaves them mkDefault for exactly this. Both Apple Silicon
  # hosts are ten-core (M1 Pro and M1 Max alike), so the same
  # half-the-machine policy lands on five: cores 5 so the worst case of
  # max-jobs x cores is the whole machine rather than 160% of it, and a
  # CPUQuota to match.
  nix.settings.cores = 5;
  systemd.services.nix-daemon.serviceConfig.CPUQuota = "500%";

  # splash.nix sizes its logo off local.splash.panelHeightPx, left at the
  # default here: studio-m1-max drives an external display whose height isn't
  # known until it's installed. bookpro14-m1-pro sets its own.
  #
  # The splash itself is confirmed working on bookpro14-m1-pro; still
  # unverified on studio-m1-max, which isn't installed yet.
}
