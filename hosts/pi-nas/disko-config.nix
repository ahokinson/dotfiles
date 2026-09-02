# Only the external USB3 SSD that holds the actual share. The SD card
# itself isn't disko-managed - see hosts/pi-nas/default.nix's fileSystems
# and hosts/pi-hole/disko-config.nix's old comment for why (nixos-
# raspberrypi's installer SD card is already partitioned/labeled by the
# sd-image build, and disko can't safely wipe the disk it's actively
# booted from without kexec, which the Pi doesn't support).
{
  disko.devices.disk.developer-ssd = {
    type = "disk";
    # Real value only knowable once the drive is physically attached -
    # `ls -l /dev/disk/by-id` on the Pi once, the same way
    # hardware-configuration.nix's by-uuid entries get filled in elsewhere
    # in this repo after install. by-id rather than /dev/sda so the
    # assignment survives a reboot regardless of USB enumeration order.
    device = "/dev/disk/by-id/usb-WD_Elements_2621_57583432413535343454354E-0:0";
    content = {
      type = "gpt";
      partitions.developer = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/srv/developer";
          mountOptions = [ "noatime" ];
        };
      };
    };
  };
}
