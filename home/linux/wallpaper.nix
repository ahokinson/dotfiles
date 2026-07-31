# Managed desktop wallpaper: the same solid Catppuccin Frappe base-color
# (#303446) image used on macOS. Shared across NixOS (KDE Plasma) and Asahi
# (GNOME) — each desktop needs a completely different mechanism, so this
# detects which is present at runtime via `command -v` rather than assuming
# one per host. Both `plasma-apply-wallpaperimage` (Plasma) and `gsettings`
# (GNOME) are already provided by their respective desktop's own system
# packages, so this deliberately calls them by name instead of referencing
# a nix package directly — that would force building/fetching the other
# desktop's packages on hosts that never use them.
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
    if command -v gsettings >/dev/null 2>&1; then
      run gsettings set org.gnome.desktop.background picture-uri "file://${wallpaperPath}"
      run gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaperPath}"
    fi
  '';
}
