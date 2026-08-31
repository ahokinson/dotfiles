# ClamAV antivirus, replacing the ESET subscription that doesn't exist for
# Linux. Daemon + signature updater on every NixOS host, plus on-access
# scanning of ~/Downloads (the directory malware actually arrives through).
# Scanning is fanotify-based and blocks access until the scan completes;
# pointing it at all of /home would tax every file open for little gain.
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

  # clamd waits on freshclam upstream, which waits on network-online, which
  # costs ~5s to a failed lookup and a retry on every boot - and multi-user
  # waits on clamd, so the greeter waits too. clamd loads the signatures
  # already on disk; the updater keeps running on its own timer.
  systemd.services.clamav-daemon.after = lib.mkForce [ ];
}
