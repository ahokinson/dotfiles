# A solid Mocha base-color (#1e1e2e) image. No declarative desktop-picture
# option exists, so this is osascript in a home-manager hook, which runs as
# the logged-in user; nix-darwin's activation runs as root and would not
# reach the Finder session.
{
  selfPath,
  config,
  lib,
  ...
}:
let
  wallpaper = selfPath "home/common/_files/wallpaper-mocha-base.png";
  wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/mocha-base.png";
in
{
  home.file."Pictures/Wallpapers/mocha-base.png".source = wallpaper;

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaperPath}"'
  '';
}
