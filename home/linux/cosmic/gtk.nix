# GTK app colors and macOS-style window-button order, via WhiteSur. Split
# from home/linux/catppuccin.nix's icon and cursor theming because everything
# here needs COSMIC to own the session.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # close, minimize, zoom. The trailing colon puts them on the left.
  decorationLayout = "close,minimize,maximize:";

  # Static because apply_theme_global is off (theme.nix), so
  # cosmic-settings-daemon never supplies these.
  #
  # COSMIC's generated GTK colour palette, captured into the repo. Normally
  # cosmic-settings-daemon writes this itself and symlinks
  # ~/.config/gtk-{3,4}.0/gtk.css at it, driven by
  # appearance.toolkit.apply_theme_global. That setting is off (see
  # home/linux/cosmic/theme.nix), because the daemon owning gtk.css means
  # home-manager cannot put anything else there — and gtk.css is the only
  # user-level CSS hook libadwaita apps respect, so it is the one place the
  # macOS window-control styling in this file can live.
  #
  # Values are what COSMIC derived from theme.nix's accent (#8caaee) and
  # bg_color (#303446). Regenerate by flipping apply_theme_global back on for
  # one switch and pasting ~/.config/gtk-4.0/cosmic/dark.css's contents over
  # the string below.
  palette = ''
    @define-color window_bg_color rgba(48, 52, 70, 1.00);
    @define-color window_fg_color rgba(195, 201, 224, 1.00);

    @define-color view_bg_color rgba(62, 66, 85, 1.00);
    @define-color view_fg_color rgba(212, 217, 240, 1.00);

    @define-color headerbar_bg_color rgba(48, 52, 70, 1.00);
    @define-color headerbar_fg_color rgba(195, 201, 224, 1.00);
    @define-color headerbar_border_color_color rgba(77, 82, 101, 1.00);
    @define-color headerbar_backdrop_color rgba(48, 52, 70, 1.00);

    @define-color sidebar_bg_color rgba(62, 66, 85, 1.00);
    @define-color sidebar_fg_color rgba(212, 217, 240, 1.00);
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.08);
    @define-color sidebar_backdrop_color rgba(77, 81, 99, 1.00);

    @define-color secondary_sidebar_bg_color rgba(75, 80, 99, 1.00);
    @define-color secondary_sidebar_fg_color rgba(229, 234, 255, 1.00);
    @define-color secondary_sidebar_shade_color rgba(0, 0, 0, 0.08);
    @define-color secondary_sidebar_backdrop_color rgba(90, 94, 112, 1.00);

    @define-color card_bg_color rgba(70, 74, 93, 1.00);
    @define-color card_fg_color rgba(221, 227, 251, 1.00);

    @define-color thumbnail_bg_color rgba(70, 74, 93, 1.00);
    @define-color thumbnail_fg_color rgba(221, 227, 251, 1.00);

    @define-color dialog_bg_color rgba(62, 66, 85, 1.00);
    @define-color dialog_fg_color rgba(212, 217, 240, 1.00);

    @define-color popover_bg_color rgba(70, 74, 93, 1.00);
    @define-color popover_fg_color rgba(221, 227, 251, 1.00);

    @define-color shade_color rgba(0, 0, 0, 0.32);
    @define-color scrollbar_outline_color rgba(48, 52, 70, 0.50);

    @define-color accent_color rgba(140, 170, 238, 1.00);
    @define-color accent_bg_color rgba(140, 170, 238, 1.00);
    @define-color accent_fg_color rgba(0, 0, 0, 1.00);

    @define-color destructive_color rgba(253, 161, 160, 1.00);
    @define-color destructive_bg_color rgba(253, 161, 160, 1.00);
    @define-color destructive_fg_color rgba(0, 0, 0, 1.00);

    @define-color warning_color rgba(247, 224, 98, 1.00);
    @define-color warning_bg_color rgba(247, 224, 98, 1.00);
    @define-color warning_fg_color rgba(0, 0, 0, 1.00);

    @define-color success_color rgba(146, 207, 156, 1.00);
    @define-color success_bg_color rgba(146, 207, 156, 1.00);
    @define-color success_fg_color rgba(0, 0, 0, 1.00);

    @define-color accent_color rgba(140, 170, 238, 1.00);
    @define-color accent_bg_color rgba(140, 170, 238, 1.00);
    @define-color accent_fg_color rgba(0, 0, 0, 1.00);

    @define-color error_color rgba(253, 161, 160, 1.00);
    @define-color error_bg_color rgba(253, 161, 160, 1.00);
    @define-color error_fg_color rgba(0, 0, 0, 1.00);

    @define-color blue_1 rgba(113, 221, 236, 1.00);
    @define-color blue_2 rgba(106, 215, 230, 1.00);
    @define-color blue_3 rgba(99, 208, 223, 1.00);
    @define-color blue_4 rgba(70, 182, 197, 1.00);
    @define-color blue_5 rgba(36, 157, 172, 1.00);

    @define-color green_1 rgba(159, 220, 169, 1.00);
    @define-color green_2 rgba(152, 214, 162, 1.00);
    @define-color green_3 rgba(146, 207, 156, 1.00);
    @define-color green_4 rgba(121, 181, 132, 1.00);
    @define-color green_5 rgba(97, 156, 108, 1.00);

    @define-color yellow_1 rgba(254, 231, 105, 1.00);
    @define-color yellow_2 rgba(250, 227, 101, 1.00);
    @define-color yellow_3 rgba(247, 224, 98, 1.00);
    @define-color yellow_4 rgba(217, 194, 64, 1.00);
    @define-color yellow_5 rgba(188, 165, 17, 1.00);

    @define-color red_1 rgba(255, 174, 172, 1.00);
    @define-color red_2 rgba(255, 167, 166, 1.00);
    @define-color red_3 rgba(253, 161, 160, 1.00);
    @define-color red_4 rgba(225, 136, 136, 1.00);
    @define-color red_5 rgba(198, 112, 112, 1.00);

    @define-color orange_1 rgba(255, 186, 38, 1.00);
    @define-color orange_2 rgba(255, 179, 24, 1.00);
    @define-color orange_3 rgba(255, 173, 0, 1.00);
    @define-color orange_4 rgba(227, 147, 0, 1.00);
    @define-color orange_5 rgba(200, 122, 0, 1.00);

    @define-color purple_1 rgba(225, 142, 255, 1.00);
    @define-color purple_2 rgba(216, 134, 255, 1.00);
    @define-color purple_3 rgba(207, 125, 255, 1.00);
    @define-color purple_4 rgba(183, 102, 230, 1.00);
    @define-color purple_5 rgba(160, 79, 205, 1.00);
    @define-color light_0 rgba(0, 0, 0, 1.00);
    @define-color light_1 rgba(5, 5, 5, 1.00);
    @define-color light_2 rgba(27, 27, 27, 1.00);
    @define-color light_3 rgba(54, 54, 54, 1.00);
    @define-color light_4 rgba(84, 84, 84, 1.00);
    @define-color dark_0 rgba(115, 115, 115, 1.00);
    @define-color dark_1 rgba(148, 148, 148, 1.00);
    @define-color dark_2 rgba(182, 182, 182, 1.00);
    @define-color dark_3 rgba(218, 218, 218, 1.00);
    @define-color dark_4 rgba(255, 255, 255, 1.00);
  '';

  whitesurTheme = pkgs.whitesur-gtk-theme.override {
    altVariants = [ "normal" ];
    colorVariants = [ "dark" ];
  };
  # Uppercase "Dark" is whitesur-gtk-theme's own directory casing, and
  # runCommand builds a literal store path from it. whitesur-icon-theme uses
  # lowercase "WhiteSur-dark" elsewhere; both spellings are correct.
  themeName = "WhiteSur-Dark";

  # WhiteSur's gtk-4.0/gtk.css is a symlink to the GTK3 stylesheet, which has
  # no windowcontrols rules, so importing it makes the theme look inert.
  # Unpacking gtk.gresource, as upstream's install.sh --libadwaita does, gives
  # a real directory whose relative url()s still resolve.
  whitesurGtk4 =
    pkgs.runCommand "whitesur-gtk4-${themeName}"
      {
        # glib.dev, not glib.bin: gresource ships in the dev output.
        nativeBuildInputs = [ pkgs.glib.dev ];
      }
      ''
        bundle=${whitesurTheme}/share/themes/${themeName}/gtk-4.0/gtk.gresource
        mkdir -p $out
        for res in $(gresource list "$bundle"); do
          # Keeping everything below "theme/" preserves the assets/ subdir
          # the stylesheet's relative url()s point at.
          rel=''${res##*/theme/}
          mkdir -p "$out/$(dirname "$rel")"
          gresource extract "$bundle" "$res" > "$out/$rel"
        done
        # Fail the build rather than ship a stylesheet that styles nothing.
        test -s $out/gtk.css
        grep -q windowcontrols $out/gtk.css
        test -s $out/windows-assets/titlebutton-close-dark.png
      '';
in
{
  gtk = {
    enable = true;

    # User CSS is the only hook libadwaita respects, and this is what puts
    # the @import at the top of ~/.config/gtk-4.0/gtk.css. Set explicitly
    # rather than inherited from gtk.theme, deprecated in stateVersion 26.05.
    theme = {
      name = themeName;
      package = whitesurTheme;
    };
    # Null on purpose: home-manager would otherwise import the GTK3-symlink
    # trap above. extraCss does the equivalent import by hand.
    gtk4.theme = null;

    font = {
      name = sharedFonts.generalFamily;
      size = sharedFonts.pointSize;
    };

    # Fallback for apps that read settings.ini rather than the portal.
    gtk3.extraConfig = {
      "gtk-decoration-layout" = decorationLayout;
      "gtk-application-prefer-dark-theme" = true;
    };
    gtk4.extraConfig."gtk-decoration-layout" = decorationLayout;

    # @import first, as GTK requires; the palette follows so it wins wherever
    # WhiteSur names a color rather than using a literal.
    gtk4.extraCss = ''
      @import url("file://${whitesurGtk4}/gtk.css");
    ''
    + palette;
    gtk3.extraCss = palette;
  };

  # cosmic-settings-daemon symlinks these into its generated cosmic/dark.css,
  # and home-manager fails activation rather than replace a foreign symlink.
  # Forcing keeps the switch self-healing if the daemon reclaims them.
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;

  # This is what actually moves the buttons: GTK4 asks
  # org.freedesktop.portal.Settings, and a portal answer overrides
  # settings.ini, leaving the extraConfig entries above inert on their own.
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = decorationLayout;

  # Mirrors home/linux/catppuccin.nix's cursor theme into GTK.
  home.pointerCursor.gtk.enable = true;
}
