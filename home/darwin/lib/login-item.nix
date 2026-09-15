# Registers an .app as a Login Item via osascript. A home-manager hook, not a
# nix-darwin one: Login Items are user-session state and nix-darwin's
# activation runs as root. Used by monitorcontrol.nix and thaw.nix.
{ lib, config }:
{ name }:
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  run /usr/bin/osascript -e '
    tell application "System Events"
      if not (exists login item "${name}") then
        make login item at end with properties {path:"${config.home.homeDirectory}/Applications/Home Manager Apps/${name}.app", hidden:false}
      end if
    end tell
  '
''
