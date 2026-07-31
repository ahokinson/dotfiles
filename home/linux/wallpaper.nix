# Managed desktop wallpaper: the same solid Catppuccin Frappe base-color
# (#303446) image used on macOS. Shared across every Linux host (NixOS and
# Asahi both run KDE Plasma). Calls `plasma-apply-wallpaperimage` by name
# via `command -v` rather than referencing a nix package directly, so this
# always resolves to whichever Plasma install actually owns the session
# (Nix-built on NixOS, Fedora's own RPM-installed build on Asahi) instead of
# forcing a Nix-built Plasma tool to run against a foreign-distro session.
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
