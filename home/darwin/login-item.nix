# Registers a nix-darwin-installed .app as a macOS Login Item via
# osascript/System Events. nix-darwin's own activation scripts run as root
# and can't touch user-session Login Item state, so this runs as a
# home-manager activation hook instead. Used by monitorcontrol.nix and
# thaw.nix.
{ lib }:
{ name, appPath }:
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  run /usr/bin/osascript -e '
    tell application "System Events"
      if not (exists login item "${name}") then
        make login item at end with properties {path:"${appPath}", hidden:false}
      end if
    end tell
  '
''
