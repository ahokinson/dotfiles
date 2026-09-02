# Registers pi-nas's "Developer" Samba share for hosts that opt in by
# importing this, as a short `sudo mount /mnt/developer` instead of typing
# the full `mount -t cifs //pi-nas.home.arpa/Developer ...` incantation.
# No stored credential of any kind, encrypted or not, in this repo or on
# disk - no `credentials=`/`password=` option means mount.cifs prompts
# interactively every time, same as ssh.nix's authorized_keys and
# hosts/pi-nas/default.nix's smbpasswd draw the same line by hand instead.
# That does mean no `x-systemd.automount`: a systemd unit has no terminal
# to prompt into, so unattended automount and an interactive password are
# mutually exclusive - this repo's call is to keep the prompt.
{ config, username, ... }:
{
  fileSystems."/mnt/developer" = {
    device = "//pi-nas.home.arpa/Developer";
    fsType = "cifs";
    options = [
      "username=${username}"
      # 1000, not a dynamic lookup: modules/nixos/user.nix never pins a UID
      # for normal users, so config.users.users.${username}.uid is null at
      # eval time (the real value only exists once useradd assigns it at
      # activation) - that silently rendered as an empty "uid=" here,
      # which the CIFS client then defaulted to root. Confirmed via
      # `id anders` on studio-m1-max; verify this still matches if this
      # module gets imported on a host where anders landed on a different
      # UID.
      "uid=1000"
      "gid=${toString config.users.groups.users.gid}"
      # Matches what actually worked against pi-nas's Samba server this
      # session - the kernel cifs client's default Kerberos-first
      # negotiation fails against a standalone (non-domain) server instead
      # of falling back to NTLM the way smbclient does.
      "sec=ntlmssp"
      "noauto"
      "_netdev"
      # Otherwise mounting fails outright if /mnt/developer doesn't already
      # exist - NixOS doesn't pre-create mountpoints for noauto entries the
      # way it does for ones mounted at boot. Same option disko itself uses
      # under the hood.
      "X-mount.mkdir"
    ];
  };

  # A friendlier address than /mnt/developer. Purely cosmetic - following
  # it into an empty directory when the share isn't currently mounted is
  # expected; `sudo mount /mnt/developer` (or ~/Developer, same target)
  # still has to happen first. "L+" (over plain "L") replaces whatever's
  # there on every activation instead of only creating it once, so this
  # self-heals if anything else ever ends up at that path.
  systemd.tmpfiles.rules = [
    "L+ /home/${username}/Developer - - - - /mnt/developer"
  ];
}
