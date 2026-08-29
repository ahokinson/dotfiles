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

        # The dock's hover fill is not settable here. libcosmic draws applet
        # icon buttons from the derived theme's text_button, whose hover is
        # control_steps_array[5] at 0.2 alpha - a neutral step. ThemeBuilder,
        # which is what this attrset writes, has no text_button field, and
        # the only lever on that neutral is neutral_tint, which recolors
        # every surface in the theme. So the shape below is the part worth
        # changing; the fill stays grey.
        #
        # Shape of that highlight. Button::AppletIcon never sets its own
        # radius, so it falls through to libcosmic's default of radius_xl -
        # 160.0 out of the box, which rounds a dock-sized button into a blob.
        # 8.0 makes it a crisp square. That is the fallback for every button
        # style not picking its own radius, so this is deliberately a global
        # change rather than a dock-only one.
        #
        # All six are listed because the option is a submodule: setting one
        # radius instantiates it and leaves the rest undefined. The other five
        # are COSMIC's stock values.
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
      # Off, despite being the setting that extends COSMIC's theme to
      # non-COSMIC apps: with it on, cosmic-settings-daemon owns
      # ~/.config/gtk-{3,4}.0/gtk.css and reclaims it on every switch,
      # fighting home-manager for the same file. COSMIC's palette is instead
      # checked in as static data at _files/gtk-palette.css and applied via
      # gtk.nix, so GTK apps keep COSMIC's colors either way. Qt apps are
      # what's actually lost (kdeglobals/qt5ct/qt6ct), and nothing else
      # themes Qt on this host.
      apply_theme_global = false;

      # icon_theme is set by home/linux/icons, which owns both this
      # and GTK's equivalent so the two cannot drift apart.

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
