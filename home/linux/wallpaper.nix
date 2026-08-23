# Managed desktop wallpaper: the same solid Catppuccin Frappe base-color
# (#303446) image used on macOS. Shared across every Linux host.
# home/linux/cosmic/wallpaper.nix handles wallpaper declaratively on COSMIC
# hosts; this activation script is a no-op there and only fires if a
# Plasma-based session (`plasma-apply-wallpaperimage`) is ever present again,
# looked up via `command -v` rather than a nix package reference so it
# always resolves to whichever Plasma install actually owns the session.
{ selfPath, config, lib, ... }:
let
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
  wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/frappe-base.png";
in {
  home.file."Pictures/Wallpapers/frappe-base.png".source = wallpaper;

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
      run plasma-apply-wallpaperimage "${wallpaperPath}"
    fi
  '';
}
