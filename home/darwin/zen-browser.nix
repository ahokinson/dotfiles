{ lib, selfPath, ... }: {
  imports = [ (selfPath "home/common/zen/extensions.nix") ];

  programs.zen-browser.enable = true;

  # Mac-only rather than in zen/extensions.nix's shared list: it syncs
  # Safari and iCloud Keychain passwords.
  programs.zen-browser.policies.ExtensionSettings."password-manager-firefox-extension@apple.com" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/icloud-passwords/latest.xpi";
    installation_mode = "force_installed";
  };

  # One-time self-heal. programs.zen-browser.profiles regenerates
  # profiles.ini from only the profiles it knows, which orphaned the real
  # one. Undeclaring it drops home-manager's stale symlink but does not
  # restore the backup it took. Restores that backup if profiles.ini is gone.
  home.activation.restoreZenProfilesIni = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    profilesIni="$HOME/Library/Application Support/zen/profiles.ini"
    backup="$HOME/Library/Application Support/zen/profiles.ini.hm-backup"
    if [[ -e "$backup" && ! -e "$profilesIni" ]]; then
      run cp "$backup" "$profilesIni"
    fi
  '';
}
