_: {
  # Things nix-darwin has no declarative option for, enforced imperatively on
  # every activation. `|| true` throughout: a work machine's MDM profile may
  # re-lock these, and a failed disable here shouldn't fail the whole
  # activation.
  system.activationScripts.extraActivation.text = ''
    # Touch ID disabled system-wide (unlock and sudo). Biometrics aren't
    # protected against compelled unlock the way a passcode is.
    /usr/bin/bioutil -w -s -f 0 -u 0 || true

    # Screen Sharing off.
    launchctl bootout system /System/Library/LaunchDaemons/com.apple.screensharing.plist || true

    # Remote Management (Apple Remote Desktop) off.
    /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop || true
  '';
}
