# Dark mode + Catppuccin Frappe accent/background + fonts, via cosmic-manager
# (wayland.desktopManager.cosmic.appearance). Shared by every NixOS host.
#
# accent and bg_color are hex->float conversions of colors already used
# elsewhere in this repo (accent #8caaee, background #303446, the
# wallpaper's base color). Checked against catppuccin/cosmic-desktop's
# catppuccin-frappe-blue+round.ron.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;
in
{
  wayland.desktopManager.cosmic.appearance = {
    theme = {
      mode = "dark";
      # accent and bg_color are typed as a "RON optional of submodule" -
      # the { __type = "optional"; value = {...}; } wrapper is required.
      dark = {
        # #8caaee (home/common/palette.nix's blue, hex->float)
        accent = ronOptional {
          red = 0.549020;
          green = 0.666667;
          blue = 0.933333;
        };
        # #303446 (home/common/palette.nix's base, hex->float)
        bg_color = ronOptional {
          red = 0.188235;
          green = 0.203922;
          blue = 0.274510;
          alpha = 1.0;
        };
      };
    };

    toolkit = {
      # Off, despite being the setting that extends COSMIC's theme to
      # non-COSMIC apps: with it on, cosmic-settings-daemon owns
      # ~/.config/gtk-{3,4}.0/gtk.css and reclaims it on every switch,
      # fighting home-manager for the same file. COSMIC's palette is instead
      # checked in as static data at _files/gtk-palette.css and applied via
      # gtk.nix, so GTK apps keep COSMIC's colors either way. Qt apps are
      # what's actually lost (kdeglobals/qt5ct/qt6ct), and nothing else
      # themes Qt on this host.
      apply_theme_global = false;

      # COSMIC's own toolkit defaults to the "Cosmic" icon theme,
      # independent of GTK's. Without this, COSMIC Files/Settings keep
      # their stock icons while GTK apps use WhiteSur (home/linux/catppuccin.nix).
      # Lowercase "dark": this is whitesur-icon-theme's own directory casing
      # (share/icons/WhiteSur-dark/), a different package from
      # whitesur-gtk-theme's "WhiteSur-Dark" used in gtk.nix - not a typo.
      icon_theme = "WhiteSur-dark";

      # Tightens COSMIC's own chrome (padding, row heights, header bars).
      # Spacing only, not display scale. That's per-output state
      # (~/.local/state/cosmic/com.system76.CosmicComp), not something
      # cosmic-manager's compositor module exposes.
      interface_density = ronEnum "Compact";
      header_size = ronEnum "Compact";

      interface_font = {
        family = sharedFonts.generalFamily;
        stretch = ronEnum "Normal";
        style = ronEnum "Normal";
        weight = ronEnum "Normal";
      };
      monospace_font = {
        family = sharedFonts.monoFamily;
        stretch = ronEnum "Normal";
        style = ronEnum "Normal";
        weight = ronEnum "Normal";
      };
    };
  };
}
