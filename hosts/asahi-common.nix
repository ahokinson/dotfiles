# Apple-Silicon-specific overrides on top of hosts/nixos-common.nix. Each
# host's default.nix adds only its hostname and hardware-config import.
{ config, inputs, selfPath, ... }:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    (selfPath "hosts/nixos-common.nix")
  ];

  hardware.asahi.enable = true;

  # Rebuilds here need --impure, permanently.
  # hardware.asahi.peripheralFirmwareDirectory defaults to a findFirst over
  # `builtins.pathExists /boot/vendorfw/firmware.cpio`; pure eval refuses to
  # read that path, and refuses a store path too. The firmware is
  # non-redistributable, so it cannot live in the flake.
  # .github/workflows/check.yml neutralises the option so CI can still
  # type-check these hosts.

  # Broadcom Wi-Fi here needs iwd; the default wpa_supplicant backend is
  # unsupported, per nixos-apple-silicon's docs.
  networking.networkmanager.wifi.backend = "iwd";

  # nixos-apple-silicon's install guide calls for false; a plain definition
  # beats modules/nixos/boot.nix's mkDefault true.
  boot.loader.efi.canTouchEfiVariables = false;

  # The same resize framework13 avoids by forcing amdgpu. nixos-apple-silicon
  # lists its stage 1 modules as availableKernelModules and includes no
  # display driver, so plymouth draws on m1n1's framebuffer until apple-drm
  # binds. modprobe pulls drm_dma_helper and the dcp bits along with this.
  boot.initrd.kernelModules = [ "appledrm" ];

  # macOS's APFS partition on this disk. No in-tree Linux driver exists;
  # linux-apfs-rw is the out-of-tree read-write one, packaged generically as
  # `<kernelPackages>.apfs` (pkgs/top-level/linux-kernels.nix), built here
  # against nixos-apple-silicon's kernel. Loads mount -t apfs into the
  # kernel, so udisks2/Cosmic Files mount it with no further wiring.
  #
  # Read-only unless a mount explicitly passes -o readwrite - upstream calls
  # write support experimental, real risk of data corruption. No encryption
  # support at all; if the macOS side has FileVault on, this can't mount it,
  # and apfs-fuse -r <recovery-key> (read-only) is the fallback.
  #
  # Untested against the pinned kernel: no nix-daemon access from the
  # sandbox to build it, and check.yml already skips full eval of both
  # Asahi hosts.
  boot.extraModulePackages = [ config.boot.kernelPackages.apfs ];

  # Ten cores on both (M1 Pro and M1 Max), against the sixteen threads
  # modules/nixos/settings.nix's local.nix.buildCores defaults to. Same
  # half-the-machine policy, rescaled.
  local.nix.buildCores = 5;

  # local.splash.panelHeightPx is left at its default: studio-m1-max has no
  # built-in panel, so its height depends on whatever display is attached.
  # bookpro14-m1-pro sets its own.
}
