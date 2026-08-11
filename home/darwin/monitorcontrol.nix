# MonitorControl: menu-bar utility for external-display brightness/volume via
# DDC. Prebuilt-only package (nixpkgs can't build it from source), darwin-only.
# Registered as a macOS Login Item via a home-manager activation hook, same
# osascript/System Events idiom as wallpaper.nix - nix-darwin's activation
# scripts run as root and can't touch user-session Login Item state.
{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.monitorcontrol ];

  home.activation.monitorcontrolLoginItem = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -e '
      tell application "System Events"
        if not (exists login item "MonitorControl") then
          make login item at end with properties {path:"/Users/anders/Applications/Home Manager Apps/MonitorControl.app", hidden:false}
        end if
      end tell
    '
  '';
}
