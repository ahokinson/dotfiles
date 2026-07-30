{ lib, ... }: {
  programs.zen-browser.enable = true;

  # One-time self-heal: earlier attempts at this declared
  # programs.zen-browser.profiles, which makes home-manager fully own and
  # regenerate profiles.ini from only the profiles it's told about — that
  # orphaned the real profile from profiles.ini. Un-declaring the profile
  # (current state) removes home-manager's stale symlink but doesn't restore
  # what it backed up (via backupFileExtension) the first time it took over.
  # If that backup exists and profiles.ini is missing, restore it.
  home.activation.restoreZenProfilesIni = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    profilesIni="$HOME/Library/Application Support/Zen/profiles.ini"
    backup="$HOME/Library/Application Support/Zen/profiles.ini.hm-backup"
    if [[ -e "$backup" && ! -e "$profilesIni" ]]; then
      run cp "$backup" "$profilesIni"
    fi
  '';
}
