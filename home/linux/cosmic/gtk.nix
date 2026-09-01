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
  palette = builtins.readFile (selfPath "home/linux/cosmic/_files/gtk-palette.css");

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
