# ClamAV antivirus, replacing the ESET subscription that doesn't exist for
# Linux. Daemon + signature updater on every NixOS host, plus on-access
# scanning of ~/Downloads (the directory malware actually arrives through).
# Scanning is fanotify-based and blocks access until the scan completes;
# pointing it at all of /home would tax every file open for little gain.
{
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
}
