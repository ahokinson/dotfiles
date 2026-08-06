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
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
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
      wallpaper = wallpaper;
      # KPlugin.Id/library confirmed via the built catppuccin-kde derivation:
      # share/plasma/look-and-feel/Catppuccin-Frappe-Blue/contents/defaults.
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__CatppuccinFrappe-Modern";
      };
      # No branded splash screen - see header comment.
      splashScreen.theme = "None";
    };

    # Mirrors the macOS Dock (modules/darwin/system.nix: dock.orientation,
    # dock.autohide, dock.tilesize, dock.persistent-apps) so both platforms
    # feel like the same bar: bottom, floating, auto-hiding, icon-only tasks
    # sized to match the Dock's tilesize, with the same two apps pinned.
    panels = [
      {
        location = "bottom";
        floating = true;
        hiding = "autohide";
        height = 64;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:zen-beta.desktop"
                "applications:com.mitchellh.ghostty.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          # Matches the macOS menu bar clock (modules/darwin/system.nix:
          # menuExtraClock.Show24Hour/ShowDate/IsAnalog) - 24h time with
          # seconds, a custom "Wed Aug 5" date inline rather than stacked
          # underneath, and a fixed compact font (smaller than the general UI
          # font, matching fonts.small below) instead of Plasma's default of
          # scaling the clock to fill this panel's 64px height.
          {
            digitalClock = {
              date.enable = true;
              date.position = "besideTime";
              date.format = { custom = "ddd MMM d"; };
              time.format = "24h";
              time.showSeconds = "always";
              font = {
                family = sharedFonts.generalFamily;
                size = sharedFonts.pointSize - 2;
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # Disables the "Highlight Screen Edges and Hot Corners" KWin effect - no
    # typed plasma-manager option for it, and it's what flashes an accent-
    # colored bar at the bottom edge just before the autohide panel appears.
    configFile."kwinrc"."Plugins"."screenedgeEnabled" = false;

    # The lock screen (kscreenlocker) is separate from SDDM's login greeter and
    # from the desktop wallpaper; point it at the same image so it matches. Its
    # colors already follow the global CatppuccinFrappeBlue color scheme.
    kscreenlocker.appearance.wallpaper = wallpaper;

    # All categories pinned (not just general/fixedWidth) so the whole session
    # is one font instead of mixing in Plasma's defaults for toolbar/menu/etc.
    # `small` deliberately keeps a smaller size - a 12pt "small" font defeats
    # the category.
    fonts = {
      general = { family = sharedFonts.generalFamily; pointSize = sharedFonts.pointSize; };
      fixedWidth = { family = sharedFonts.monoFamily; pointSize = sharedFonts.pointSize; };
      toolbar = { family = sharedFonts.generalFamily; pointSize = sharedFonts.pointSize; };
      menu = { family = sharedFonts.generalFamily; pointSize = sharedFonts.pointSize; };
      windowTitle = { family = sharedFonts.generalFamily; pointSize = sharedFonts.pointSize; };
      small = { family = sharedFonts.generalFamily; pointSize = sharedFonts.pointSize - 4; };
    };
  };
}
