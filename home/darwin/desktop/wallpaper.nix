# A radio tower at dusk, from orangci/walls-catppuccin-mocha, already
# lutgen-converted to the Mocha palette there. Its companion
# home/linux/desktop/sessions/cosmic/wallpaper.nix picks between two others by hardware, so a
# glance at the desktop says which machine this is: this one is real macOS.
#
# No declarative desktop-picture option exists, so this is a home-manager
# activation hook, which runs as the logged-in user; nix-darwin's activation
# runs as root and would not reach the Finder session. desktoppr (not
# osascript) does the actual setting: `tell every desktop to set picture` is
# a known System Events bug that only reliably applies to the main display,
# leaving other monitors (and Spaces other than the one currently active per
# display) on the old picture. desktoppr instead calls NSWorkspace's own
# setDesktopImageURL API - what System Settings' Desktop pane itself uses -
# which applies correctly everywhere.
{
  selfPath,
  config,
  lib,
  pkgs,
  ...
}:
let
  wallpaper = selfPath "home/common/assets/wallpaper/mac.jpg";
  wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/mac.jpg";
in
{
  # On home.packages too, not just referenced by store path below - lets you
  # run `desktoppr` by hand to check/debug the current per-display picture.
  home.packages = [ pkgs.desktoppr ];

  home.file."Pictures/Wallpapers/mac.jpg".source = wallpaper;

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.desktoppr}/bin/desktoppr "${wallpaperPath}"
  '';
}
