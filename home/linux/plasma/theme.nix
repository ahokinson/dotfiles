# Shared KDE Plasma theming via plasma-manager — every Linux/Plasma host,
# NixOS and Asahi Fedora alike. Everything here writes to plain ini config
# files via plasma-manager's configFile mechanism, so it's safe against
# Asahi's Fedora-built Plasma too, not just a Nix-built one.
#
# Deliberately avoids workspace.lookAndFeel: catppuccin-kde's look-and-feel
# package forces a nonexistent cursor theme and its own splash mascot, and
# plasma-manager warns that combining lookAndFeel with explicit settings
# like windowDecorations is unreliable (the imperative apply step reruns
# every login and overwrites them). Setting each piece explicitly below
# avoids that.
#
# colorScheme/windowDecorations reference catppuccin-kde's assets (pure
# data, no compiled Qt code — none of catppuccin-qt.nix's ABI risk). NixOS
# gets it system-wide (modules/nixos/desktop-plasma.nix); Asahi has no such
# system layer, so it's a home package here, exported into the live session
# via plasma-workspace's env-script mechanism.
{ pkgs, lib, selfPath, config, osConfig ? null, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
  # osConfig is present only when wired in as a NixOS module (see panel.nix
  # for the same test and why it has to be a function arg).
  isNixOS = osConfig != null;
in
{
  home.packages = lib.optionals (!isNixOS) [ pkgs.catppuccin-kde ];

  # Only needed on Asahi — NixOS's system profile is already on
  # XDG_DATA_DIRS.
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
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__CatppuccinFrappe-Modern";
      };
      splashScreen.theme = "None"; # No branded splash screen (see header).
    };

    # Disables the "Highlight Screen Edges and Hot Corners" KWin effect - no
    # typed plasma-manager option for it, and it's what flashes an accent-
    # colored bar at the bottom edge just before the autohide panel appears.
    configFile."kwinrc"."Plugins"."screenedgeEnabled" = false;

    # Force-maximize on launch for the two apps pinned in panel.nix. Window
    # class values match their .desktop ids; "zen" is a substring match
    # since Zen's exact WM_CLASS varies by channel.
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

    # Separate from SDDM's login greeter and the desktop wallpaper; points
    # at the same image so it matches.
    kscreenlocker.appearance.wallpaper = wallpaper;

    # All categories pinned so the session is one font instead of mixing in
    # Plasma's defaults. `small` deliberately keeps a smaller size - a 12pt
    # "small" font defeats the category.
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
