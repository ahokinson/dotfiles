# Shared KDE Plasma theming via plasma-manager - every Linux/Plasma host,
# NixOS and Asahi Fedora alike. Split out of plasma.nix, which now holds only
# the workspace.wallpaper desktopScript (the one piece that actually needs a
# live D-Bus session). Everything here - colorScheme, windowDecorations,
# splashScreen, the kwinrc tweak, window-rules, fonts, and the lock-screen
# wallpaper - writes to plain ini config files via plasma-manager's
# configFile mechanism (verified against plasma-manager's
# workspace.nix/fonts.nix/kwin.nix/window-rules.nix/kscreenlocker.nix), the
# same ABI-safe approach plasma-panel.nix already uses, so it's safe against
# Asahi's Fedora-built Plasma too, not just a Nix-built one.
#
# Deliberately avoids workspace.lookAndFeel: catppuccin-kde's look-and-feel
# package forces a nonexistent cursor theme and its own splash-screen mascot
# logo, and plasma-manager warns that combining lookAndFeel with explicit
# settings like windowDecorations is unreliable (the imperative apply step
# reruns every login and overwrites them). Setting each piece explicitly
# below avoids that and writes straight to config files at activation time.
#
# colorScheme and windowDecorations below reference assets from the
# catppuccin-kde package - a pure-data stdenvNoCC derivation (SVGs/.colors
# files, no compiled Qt code), so installing it carries none of
# catppuccin-qt.nix's ABI risk. NixOS gets it system-wide via
# environment.systemPackages (modules/nixos/desktop.nix), already on
# XDG_DATA_DIRS by default. Asahi has no such system layer, so it's a home
# package here instead, with its share/ exported into the live session via
# plasma-workspace's own env-script mechanism - startplasma sources every
# ~/.config/plasma-workspace/env/*.sh before launching kwin/plasmashell, the
# same "needs a guaranteed-live-session hook, not home.activation" fix
# workspace.wallpaper needed in plasma.nix.
{ pkgs, lib, selfPath, config, osConfig ? null, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
  # osConfig is present only when wired in as a NixOS module (see
  # plasma-panel.nix for the same test and why it has to be a function arg).
  isNixOS = osConfig != null;
in
{
  home.packages = lib.optionals (!isNixOS) [ pkgs.catppuccin-kde ];

  # Only needed on Asahi - see header comment. NixOS's system profile is
  # already on XDG_DATA_DIRS, so this would just be redundant there.
  xdg.configFile."plasma-workspace/env/nix-profile-data-dirs.sh" = lib.mkIf (!isNixOS) {
    text = ''
      export XDG_DATA_DIRS="${config.home.profileDirectory}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
    '';
  };

  programs.plasma = {
    workspace = {
      # Matches CatppuccinFrappeBlue.colors in share/color-schemes/.
      colorScheme = "CatppuccinFrappeBlue";
      # No cursor.theme override - the Catppuccin cursor theme isn't good,
      # so this stays on Plasma's default (Breeze).
      # KPlugin.Id/library confirmed via the built catppuccin-kde derivation:
      # share/plasma/look-and-feel/Catppuccin-Frappe-Blue/contents/defaults.
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__CatppuccinFrappe-Modern";
      };
      # No branded splash screen - see header comment.
      splashScreen.theme = "None";
    };

    # Disables the "Highlight Screen Edges and Hot Corners" KWin effect - no
    # typed plasma-manager option for it, and it's what flashes an accent-
    # colored bar at the bottom edge just before the autohide panel appears.
    configFile."kwinrc"."Plugins"."screenedgeEnabled" = false;

    # Force-maximize on launch for the two apps pinned above. Window class
    # values match their .desktop ids (iconTasks.launchers); "zen" is a
    # substring match since Zen's exact WM_CLASS varies by channel
    # (zen-beta/zen/zen-twilight).
    window-rules = [
      {
        description = "Force maximize Zen Browser";
        match.window-class = {
          value = "zen";
          type = "substring";
        };
        apply = {
          maximizehoriz = {
            value = true;
            apply = "force";
          };
          maximizevert = {
            value = true;
            apply = "force";
          };
        };
      }
      {
        description = "Force maximize Ghostty";
        match.window-class = {
          value = "com.mitchellh.ghostty";
          type = "substring";
        };
        apply = {
          maximizehoriz = {
            value = true;
            apply = "force";
          };
          maximizevert = {
            value = true;
            apply = "force";
          };
        };
      }
    ];

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
