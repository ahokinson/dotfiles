_: {
  # No declarative option for any of these. `|| true` throughout: a work
  # machine's MDM profile may re-lock them, which must not fail activation.
  system.activationScripts.extraActivation.text = ''
    # Touch ID off for unlock and sudo: no compelled-unlock protection.
    /usr/bin/bioutil -w -s -f 0 -u 0 || true

    launchctl bootout system /System/Library/LaunchDaemons/com.apple.screensharing.plist || true

    /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop || true
  '';
}
