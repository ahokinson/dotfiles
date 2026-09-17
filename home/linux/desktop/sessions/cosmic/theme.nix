# accent and bg_color are hex->float conversions of palette.nix colors,
# checked against catppuccin/cosmic-desktop's catppuccin-mocha-blue+round.ron.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/theme/fonts.nix") { inherit pkgs; };
  inherit (import (selfPath "home/linux/desktop/sessions/cosmic/ron.nix")) ronOptional ronEnum;

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
        # #89b4fa (home/common/theme/palette.nix's blue, hex->float)
        accent = ronOptional {
          red = 0.537255;
          green = 0.705882;
          blue = 0.980392;
        };
        # #1e1e2e (home/common/theme/palette.nix's base, hex->float)
        bg_color = ronOptional {
          red = 0.117647;
          green = 0.117647;
          blue = 0.180392;
          # 0.867, not the stock 1.0: repo-wide frosted-glass transparency,
          # matched to fuzzel's own shipped alpha.
          alpha = 0.867;
        };

        # Flat everywhere, to match Sway, which has no rounding concept at
        # all. All six are listed because the option is a submodule: setting
        # one instantiates it and leaves the rest undefined.
        corner_radii = {
          radius_0 = radius 0.0;
          radius_xs = radius 0.0;
          radius_s = radius 0.0;
          radius_m = radius 0.0;
          radius_l = radius 0.0;
          radius_xl = radius 0.0;
        };
      };
    };

    toolkit = {
      # With this on, cosmic-settings-daemon owns ~/.config/gtk-{3,4}.0/gtk.css
      # and reclaims it on every switch, fighting home-manager for the file.
      # GTK apps get COSMIC's palette from gtk.nix instead. Qt theming
      # (kdeglobals/qt5ct/qt6ct) is what is lost.
      apply_theme_global = false;

      # icon_theme is set by home/linux/desktop/icons, which owns GTK's too.

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
