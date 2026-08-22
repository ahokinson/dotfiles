# Turns on home-manager's GTK module so the GTK-app settings the rest of this
# repo declares actually reach disk. Without `gtk.enable` the whole module is
# a no-op (it's `mkIf cfg.enable`), which is why home/linux/catppuccin.nix's
# `gtk.iconTheme = "WhiteSur-dark"` wrote nothing and GTK apps kept rendering
# with the Plasma-era ~/.config/gtk-3.0/settings.ini (breeze icons,
# breeze_cursors, Windows-order window buttons) left behind on this machine.
#
# COSMIC-scoped rather than added to catppuccin.nix, which is shared with the
# Asahi Fedora host: Plasma's kde-gtk-config rewrites settings.ini itself at
# login, so home-manager owning that file there would be a tug-of-war.
#
# This file also owns GTK app colors, which cosmic-settings-daemon used to
# supply. It had to take them over: the daemon symlinks
# ~/.config/gtk-{3,4}.0/gtk.css at a palette it generates, and gtk.css is the
# only user-level CSS hook libadwaita apps respect, so the two cannot both
# have it. theme.nix turns appearance.toolkit.apply_theme_global off and the
# palette moves here as _files/gtk-palette.css. See that file and theme.nix
# for the full reasoning and what it costs.
#
# The macOS window controls come from the WhiteSur GTK theme rather than
# hand-written CSS. Setting gtk.theme is also what reaches libadwaita apps:
# home-manager prepends an @import of the theme to gtk.css, and user CSS is
# the only hook libadwaita honours.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # macOS window-button order — close, minimize, zoom — on the leading side.
  # The trailing colon is what puts them on the left.
  decorationLayout = "close,minimize,maximize:";

  # COSMIC's colors, which the daemon no longer supplies now that
  # apply_theme_global is off - see the file's own header and theme.nix.
  palette = builtins.readFile (selfPath "home/linux/cosmic/_files/gtk-palette.css");

  # The GTK counterpart to the WhiteSur icons and cursors in
  # home/linux/catppuccin.nix, and where the macOS window controls come from:
  # altVariants is nixpkgs' "window control buttons variants", and its default
  # ("normal") is the BigSur traffic lights. Doing it through the theme rather
  # than hand-written CSS also brings the rest of the macOS widget shapes,
  # which hand-written rules would never have covered.
  whitesurTheme = pkgs.whitesur-gtk-theme.override {
    altVariants = [ "normal" ];
    colorVariants = [ "dark" ];
  };
  themeName = "WhiteSur-Dark";

  # WhiteSur ships its GTK4 theme compiled into gtk.gresource, and leaves
  # gtk-4.0/gtk.css as a symlink to the GTK3 stylesheet. That symlink is a
  # trap: importing it into GTK4 pulls in GTK3 CSS, which styles none of
  # GTK4's nodes (no `windowcontrols` rules at all), so the theme appears to
  # do nothing. The 66 windowcontrols rules are inside the bundle.
  #
  # Unpacking it here gives a plain directory whose gtk.css can be imported
  # by file:// URL, with the PNG assets alongside it so the relative url()s
  # in the stylesheet still resolve. This is the same thing upstream's
  # install.sh --libadwaita does, which exists for exactly this reason.
  whitesurGtk4 = pkgs.runCommand "whitesur-gtk4-${themeName}" {
    # glib.dev, not glib.bin: gresource ships in the dev output.
    nativeBuildInputs = [ pkgs.glib.dev ];
  } ''
    bundle=${whitesurTheme}/share/themes/${themeName}/gtk-4.0/gtk.gresource
    mkdir -p $out
    for res in $(gresource list "$bundle"); do
      # Paths are /org/gnome/theme/{gtk.css,gtk-dark.css,assets/...} - the
      # bundle's own prefix, not the /org/gtk/libgtk/theme/<name>/ layout GTK4
      # looks themes up under. Keeping everything below "theme/" preserves the
      # assets/ subdirectory the stylesheet's relative url()s point at.
      rel=''${res##*/theme/}
      mkdir -p "$out/$(dirname "$rel")"
      gresource extract "$bundle" "$res" > "$out/$rel"
    done
    # Fail the build rather than silently produce a stylesheet that styles
    # nothing: the window controls are what this whole detour is for, and they
    # are drawn from windows-assets/*.png rather than plain CSS colours.
    test -s $out/gtk.css
    grep -q windowcontrols $out/gtk.css
    test -s $out/windows-assets/titlebutton-close-dark.png
  '';
in
{
  gtk = {
    enable = true;

    # Setting this is also what gets the theme into libadwaita apps. GTK4
    # ignores gtk-theme-name, but home-manager's gtk4 module reacts to a theme
    # with a package by writing `@import url("file://.../gtk-4.0/gtk.css")` at
    # the top of ~/.config/gtk-4.0/gtk.css - and user CSS is the one hook
    # libadwaita does respect. gtk4.theme is set explicitly rather than left to
    # inherit gtk.theme, because that inheritance is deprecated as of
    # stateVersion 26.05.
    theme = {
      name = themeName;
      package = whitesurTheme;
    };
    # Explicitly null: home-manager would otherwise import
    # <theme>/gtk-4.0/gtk.css, which is the GTK3 symlink described above. The
    # import it would have written is done by hand in extraCss instead,
    # pointing at the unpacked bundle.
    gtk4.theme = null;

    font = {
      name = sharedFonts.generalFamily;
      size = sharedFonts.pointSize;
    };

    # Fallback copy of the button layout below, for any GTK app that reads
    # settings.ini rather than the portal. Under COSMIC this file loses to
    # dconf - see the dconf.settings block - so it is not the one doing the
    # work, but it costs nothing and covers the no-portal case.
    gtk3.extraConfig = {
      "gtk-decoration-layout" = decorationLayout;
      # Plasma used to set this; GTK4 gets dark from the portal's
      # color-scheme, but GTK3 apps still read it here.
      "gtk-application-prefer-dark-theme" = true;
    };
    gtk4.extraConfig."gtk-decoration-layout" = decorationLayout;

    # COSMIC apps are unaffected by any of this - they draw their headerbars
    # through libcosmic rather than GTK, so they keep square monochrome
    # buttons on the right.
    # @import first, as GTK requires. The palette follows it so these
    # definitions win wherever WhiteSur refers to a colour by name rather than
    # baking a literal in - macOS shapes, Catppuccin colours, as far as that
    # goes.
    gtk4.extraCss = ''
      @import url("file://${whitesurGtk4}/gtk.css");
    ''
    + palette;

    # GTK3 loads the theme itself from gtk-theme-name, so it needs no import -
    # just the palette, which its gtk.css used to get from the daemon.
    gtk3.extraCss = palette;
  };

  # These were symlinks cosmic-settings-daemon made into its generated
  # cosmic/dark.css, and backupFileExtension only rescues regular files —
  # home-manager refuses to replace a foreign symlink and fails activation
  # instead. With apply_theme_global off the daemon should stop reclaiming
  # them, but forcing keeps the switch self-healing if it ever does.
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;

  # This is what actually moves the window buttons under COSMIC. GTK4 asks
  # org.freedesktop.portal.Settings for org.gnome.desktop.wm.preferences'
  # button-layout, xdg-desktop-portal answers out of GSettings, and a portal
  # answer overrides settings.ini - so the gtk*.extraConfig entries above are
  # inert here on their own. The value this replaces was
  # "icon:minimize,maximize,close", left in dconf by Plasma's kde-gtk-config.
  #
  # Only GTK apps are affected. COSMIC draws its own server-side titlebars and
  # has no button-layout setting at all (com.system76.CosmicTk exposes just
  # show_minimize/show_maximize), so COSMIC-native windows stay right-handed.
  # Ghostty picks this up because home/common/ghostty/default.nix asks for
  # client-side decorations on Linux.
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = decorationLayout;

  # Mirrors home/linux/catppuccin.nix's home.pointerCursor into gtk.cursorTheme
  # (settings.ini + the org/gnome/desktop/interface dconf keys), so GTK apps
  # use WhiteSur at the same size as the COSMIC compositor instead of whatever
  # the stale settings.ini said.
  home.pointerCursor.gtk.enable = true;
}
