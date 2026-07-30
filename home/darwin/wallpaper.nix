# Managed desktop wallpaper: a solid Catppuccin Frappe base-color (#303446)
# image, matching the dark theme used across terminal/editor/CLI tooling.
# nix-darwin has no declarative desktop-picture option, so this sets it via
# `osascript` in a home-manager activation hook, which runs as the logged-in
# user (unlike nix-darwin's system activation scripts, which run as root and
# wouldn't affect the user's Finder/Dock session state).
{ config, lib, ... }:
let
  wallpaper = ./_files/wallpaper-frappe-base.png;
  wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/frappe-base.png";
in {
  home.file."Pictures/Wallpapers/frappe-base.png".source = wallpaper;

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaperPath}"'
  '';
}
