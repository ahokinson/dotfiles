# Raspberry Pi 4, Samba NAS for shared developer projects. Only what this
# host is for; the rest is in hosts/raspberrypi-common.nix.
# First install: see README's "First activation on a new Raspberry Pi".
# After that: rsync this repo to the box and run
# `sudo nixos-rebuild switch --flake .#pi-nas` there directly - see
# hosts/pi-hole/default.nix's header comment for why `--target-host`
# doesn't work on these hosts.
{ inputs, selfPath, ... }:
{
  networking.hostName = "pi-nas";

  imports = [
    inputs.disko.nixosModules.disko
    (selfPath "hosts/pi-nas/disko-config.nix")
    (selfPath "hosts/raspberrypi-common.nix")
  ];

  # No disko for the SD card itself - see hosts/pi-hole/default.nix's
  # comment for why. disko-config.nix only covers the SSD, which is a
  # genuinely blank disk disko can safely format.
  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "noatime"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=1min"
    ];
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # mkfs.ext4 leaves a freshly formatted filesystem's root directory owned
  # by root:root, mode 755 - Samba enforces real Unix permissions
  # underneath its own share config, so "valid users = anders" alone
  # doesn't grant anders write access. `d` (not `f`) re-asserts ownership
  # on every boot even though the directory already exists, so this
  # self-heals across a future reformat without needing to remember the
  # one-off `chown` this took to discover.
  systemd.tmpfiles.rules = [ "d /srv/developer 0755 anders users -" ];

  # A native module, unlike pi-hole - no container needed.
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "pi-nas";
        "server role" = "standalone server";
        # macOS Finder has refused SMB1 for years; nothing on this network
        # needs it, so don't offer it.
        "server min protocol" = "SMB2_10";
        "map to guest" = "never";
      };
      # "Developer", capitalized: this key is the literal share name shown
      # to SMB clients (smb://.../Developer). The mountpoint and disko's
      # own attribute names stay lowercase - clients never see those.
      "Developer" = {
        path = "/srv/developer";
        browseable = "yes";
        writable = "yes";
        "valid users" = "anders";
        # The vfs_fruit pair modern macOS clients actually need: proper
        # resource-fork/Finder metadata storage in an xattr stream instead
        # of littering the share with ._AppleDouble files.
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
      };
    };
  };

  # The Samba password is independent of the Unix one, lives in Samba's own
  # tdbsam, and is never in this repo - same line ssh.nix draws for
  # authorized_keys.
  #   smbpasswd -a anders
}
