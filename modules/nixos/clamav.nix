# On-access scanning is fanotify-based and blocks the open until the scan
# finishes, so it is pointed at ~/Downloads rather than all of /home.
{
  lib,
  username,
  ...
}:
{
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    clamonacc.enable = true;

    daemon.settings = {
      OnAccessPrevention = true;
      OnAccessIncludePath = "/home/${username}/Downloads";
    };
  };

  # Upstream has clamd wait on freshclam, which waits on network-online:
  # ~5s of failed lookup on every boot, and the greeter waits behind it.
  # clamd loads the signatures already on disk; the updater has its own timer.
  systemd.services.clamav-daemon.after = lib.mkForce [ ];
}
