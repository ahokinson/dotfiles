# accent and bg_color are hex->float conversions of palette.nix colors,
# checked against catppuccin/cosmic-desktop's catppuccin-frappe-blue+round.ron.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;

  # COSMIC takes a corner radius as one value per corner.
  radius = n: {
    __type = "tuple";
    value = [
      n
      n
      n
      n
    ];
  };
in
{
  wayland.desktopManager.cosmic.appearance = {
    theme = {
      mode = "dark";
      # Typed as a RON optional of submodule, so the wrapper is required.
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

        # The dock's hover fill is not settable from ThemeBuilder; only its
        # shape is. Button::AppletIcon sets no radius of its own and falls
        # through to radius_xl, 160.0 by default, far too round at dock-button
        # size. This is the fallback for every button style without its own
        # radius, so it is a global change, not a dock-only one.
        #
        # All six are listed because the option is a submodule: setting one
        # instantiates it and leaves the rest undefined. The other five are
        # COSMIC's stock values.
        corner_radii = {
          radius_0 = radius 0.0;
          radius_xs = radius 4.0;
          radius_s = radius 8.0;
          radius_m = radius 16.0;
          radius_l = radius 32.0;
          radius_xl = radius 8.0;
        };
      };
    };

    toolkit = {
      # With this on, cosmic-settings-daemon owns ~/.config/gtk-{3,4}.0/gtk.css
      # and reclaims it on every switch, fighting home-manager for the file.
      # GTK apps get COSMIC's palette from gtk.nix instead. Qt theming
      # (kdeglobals/qt5ct/qt6ct) is what is lost.
      apply_theme_global = false;

      # icon_theme is set by home/linux/icons, which owns GTK's too.

      # Spacing only, not display scale, which is per-output state
      # cosmic-manager's compositor module does not expose.
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
