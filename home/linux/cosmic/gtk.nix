# Turns on home-manager's GTK module (a no-op otherwise) and owns GTK app
# colors + the macOS window-button order via the WhiteSur theme.
# COSMIC-scoped rather than shared with Asahi's catppuccin.nix: Plasma's
# kde-gtk-config rewrites settings.ini itself at login, so home-manager
# owning that file there would be a tug-of-war.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # macOS window-button order — close, minimize, zoom — on the leading side.
  # The trailing colon is what puts them on the left.
  decorationLayout = "close,minimize,maximize:";

  # COSMIC's colors, kept as static data since apply_theme_global is off
  # (theme.nix) and cosmic-settings-daemon no longer supplies them.
  palette = builtins.readFile (selfPath "home/linux/cosmic/_files/gtk-palette.css");

  whitesurTheme = pkgs.whitesur-gtk-theme.override {
    altVariants = [ "normal" ];
    colorVariants = [ "dark" ];
  };
  themeName = "WhiteSur-Dark";

  # WhiteSur's gtk-4.0/gtk.css is a symlink to the GTK3 stylesheet —
  # importing it into GTK4 pulls in CSS with no windowcontrols rules, so the
  # theme looks like it does nothing. Unpacking gtk.gresource instead (same
  # fix upstream's install.sh --libadwaita uses) gives a plain directory
  # whose gtk.css can be imported by file:// URL, with the PNG assets
  # alongside it so the stylesheet's relative url()s still resolve.
  whitesurGtk4 = pkgs.runCommand "whitesur-gtk4-${themeName}" {
    # glib.dev, not glib.bin: gresource ships in the dev output.
    nativeBuildInputs = [ pkgs.glib.dev ];
  } ''
    bundle=${whitesurTheme}/share/themes/${themeName}/gtk-4.0/gtk.gresource
    mkdir -p $out
    for res in $(gresource list "$bundle"); do
      # Paths are /org/gnome/theme/{gtk.css,gtk-dark.css,assets/...}; keeping
      # everything below "theme/" preserves the assets/ subdirectory the
      # stylesheet's relative url()s point at.
      rel=''${res##*/theme/}
      mkdir -p "$out/$(dirname "$rel")"
      gresource extract "$bundle" "$res" > "$out/$rel"
    done
    # Fail the build rather than silently ship a stylesheet that styles
    # nothing.
    test -s $out/gtk.css
    grep -q windowcontrols $out/gtk.css
    test -s $out/windows-assets/titlebutton-close-dark.png
  '';
in
{
  gtk = {
    enable = true;

    # gtk4.theme is what reaches libadwaita apps — home-manager's gtk4
    # module writes an @import of the theme's own gtk.css at the top of
    # ~/.config/gtk-4.0/gtk.css, and user CSS is the only hook libadwaita
    # respects. Set explicitly rather than inherited from gtk.theme, which
    # is deprecated as of stateVersion 26.05.
    theme = {
      name = themeName;
      package = whitesurTheme;
    };
    # Explicitly null: home-manager would otherwise import the GTK3-symlink
    # trap described above. The equivalent import is done by hand in
    # extraCss instead, pointing at the unpacked bundle.
    gtk4.theme = null;

    font = {
      name = sharedFonts.generalFamily;
      size = sharedFonts.pointSize;
    };

    # Fallback for any GTK app that reads settings.ini rather than the
    # portal (under COSMIC, dconf below wins for the ones that use it).
    gtk3.extraConfig = {
      "gtk-decoration-layout" = decorationLayout;
      "gtk-application-prefer-dark-theme" = true;
    };
    gtk4.extraConfig."gtk-decoration-layout" = decorationLayout;

    # @import first, as GTK requires; the palette follows so it wins
    # wherever WhiteSur refers to a color by name rather than a literal.
    # COSMIC apps are unaffected — they draw headerbars through libcosmic,
    # not GTK.
    gtk4.extraCss = ''
      @import url("file://${whitesurGtk4}/gtk.css");
    ''
    + palette;
    gtk3.extraCss = palette;
  };

  # These were symlinks cosmic-settings-daemon made into its generated
  # cosmic/dark.css; home-manager refuses to replace a foreign symlink and
  # fails activation instead of just overwriting it. Forcing keeps the
  # switch self-healing if the daemon ever reclaims them again.
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;

  # What actually moves the window buttons under COSMIC: GTK4 asks
  # org.freedesktop.portal.Settings for the button-layout, and a portal
  # answer overrides settings.ini, making the gtk*.extraConfig entries above
  # inert on their own. COSMIC-native windows are unaffected — libcosmic has
  # no button-layout setting at all.
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = decorationLayout;

  # Mirrors home/linux/catppuccin.nix's cursor theme into GTK (settings.ini
  # + the relevant dconf keys).
  home.pointerCursor.gtk.enable = true;
}
