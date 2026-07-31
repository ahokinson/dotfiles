# KDE Plasma 6 session theming via plasma-manager - NixOS only (the only
# Plasma host; see modules/nixos/desktop.nix for the system-level SDDM theme
# + catppuccin-kde package install this activates inside a running session).
#
# Deliberately avoids workspace.lookAndFeel: catppuccin-kde's look-and-feel
# package forces a nonexistent cursor theme and its own splash-screen mascot
# logo, and plasma-manager warns that combining lookAndFeel with explicit
# settings like windowDecorations is unreliable (the imperative apply step
# reruns every login and overwrites them). Setting each piece explicitly
# below avoids that and writes straight to config files at activation time.
#
# workspace.wallpaper runs as a plasma-manager desktopScript rather than
# home/linux/wallpaper.nix's `home.activation` alone, because that activation
# runs inside the home-manager-anders systemd *system* service during
# `nixos-rebuild switch`, which lacks the live session's D-Bus bus - the
# write silently doesn't land. desktopScripts run at login instead, when a
# live session is guaranteed. wallpaper.nix's approach stays for Asahi,
# which doesn't have plasma-manager wired in.
{ pkgs, selfPath, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
in
{
  programs.plasma = {
    enable = true;

    # Reasserts these values on every activation, not just first apply -
    # otherwise a manual System Settings change drifts away from this file.
    overrideConfig = true;

    workspace = {
      # Matches CatppuccinFrappeBlue.colors in share/color-schemes/.
      colorScheme = "CatppuccinFrappeBlue";
      # No cursor.theme override - the Catppuccin cursor theme isn't good,
      # so this stays on Plasma's default (Breeze).
      wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
      # KPlugin.Id/library confirmed via the built catppuccin-kde derivation:
      # share/plasma/look-and-feel/Catppuccin-Frappe-Blue/contents/defaults.
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__CatppuccinFrappe-Modern";
      };
      # No branded splash screen - see header comment.
      splashScreen.theme = "None";
    };

    fonts = {
      general = { family = sharedFonts.generalFamily; pointSize = 10; };
      fixedWidth = { family = sharedFonts.monoFamily; pointSize = 10; };
    };
  };
}
