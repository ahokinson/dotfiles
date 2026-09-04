# A radio tower at dusk, from orangci/walls-catppuccin-mocha, already
# lutgen-converted to the Mocha palette there. Its companion
# home/linux/cosmic/wallpaper.nix picks between two others by hardware, so a
# glance at the desktop says which machine this is: this one is real macOS.
#
# No declarative desktop-picture option exists, so this is osascript in a
# home-manager hook, which runs as the logged-in user; nix-darwin's
# activation runs as root and would not reach the Finder session.
{
  selfPath,
  config,
  lib,
  ...
}:
let
  wallpaper = selfPath "home/common/_files/wallpaper/mac.jpg";
  wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/mac.jpg";
in
{
  home.file."Pictures/Wallpapers/mac.jpg".source = wallpaper;

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaperPath}"'
  '';
}
