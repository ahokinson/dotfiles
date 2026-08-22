# Dark mode + Catppuccin Frappe accent/background + fonts, via cosmic-manager
# (wayland.desktopManager.cosmic.appearance). NixOS only, framework13-only —
# there's no COSMIC/Asahi equivalent to share this with.
#
# accent and bg_color are hex->float conversions of the same colors already
# used elsewhere in this repo (accent #8caaee: modules/nixos/desktop-plasma.nix's
# SDDM theme.conf.user; background #303446: the wallpaper's base color, see
# home/common/_files/wallpaper-frappe-base.png), not hand-copied from
# upstream — cross-checked against catppuccin/cosmic-desktop's
# catppuccin-frappe-blue+round.ron, which encodes the identical values.
#
# Deliberately partial: theme.dark's other fields (corner_radii, spacing,
# the extended grey/accent ramp used for less-common UI surfaces) are left
# unset, so COSMIC's own defaults fill them in — defaultNullOpts fields only
# get written when set. Full palette parity would mean transcribing
# catppuccin/cosmic-desktop's whole per-flavor .ron file into this option
# tree (it's meant for COSMIC Settings' GUI theme import, not a drop-in
# config file — cosmic-manager writes each field as its own on-disk key
# rather than one combined file), which hasn't been done here. Revisit if
# the accent-only result doesn't read as Catppuccin enough.
{ selfPath, pkgs, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
in
{
  wayland.desktopManager.cosmic.appearance = {
    theme = {
      mode = "dark";
      # accent and bg_color are typed as a "RON optional of submodule" -
      # the { __type = "optional"; value = {...}; } wrapper is required,
      # not just the bare color attrset.
      dark = {
        # #8caaee
        accent = {
          __type = "optional";
          value = {
            red = 0.549020;
            green = 0.666667;
            blue = 0.933333;
          };
        };
        # #303446
        bg_color = {
          __type = "optional";
          value = {
            red = 0.188235;
            green = 0.203922;
            blue = 0.274510;
            alpha = 1.0;
          };
        };
      };
    };

    toolkit = {
      # Off, despite this being the setting that extends COSMIC's theme to
      # non-COSMIC apps. With it on, cosmic-settings-daemon owns
      # ~/.config/gtk-{3,4}.0/gtk.css (it symlinks them at a palette it
      # generates) and reclaims those paths on every switch, since our own
      # cosmic-ctl writes are what wake it. gtk.css is also the only
      # user-level CSS hook libadwaita apps respect, so it has to be
      # home-manager's for the macOS window-control styling in
      # home/linux/cosmic/gtk.nix to exist at all.
      #
      # The palette the daemon used to generate is kept instead as
      # _files/gtk-palette.css and prepended to that styling, so GTK apps
      # keep COSMIC's colors. What is genuinely lost is the daemon's Qt side
      # (kdeglobals, qt5ct, qt6ct) - nothing else themes Qt on this host, so
      # Qt apps fall back to their own defaults.
      apply_theme_global = false;

      # COSMIC's own toolkit defaults to the "Cosmic" icon theme, which is
      # independent of GTK's - without this, COSMIC Files/Settings keep their
      # stock icons while GTK apps use the WhiteSur set from
      # home/linux/catppuccin.nix.
      icon_theme = "WhiteSur-dark";

      # Tightens COSMIC's own chrome - padding, row heights, header bars.
      #
      # Spacing only, not display scale. The scale factor that decides how
      # large everything actually renders is per-output and lives in
      # cosmic-comp's *state* (~/.local/state/cosmic/com.system76.CosmicComp),
      # keyed by the monitor's own identity; cosmic-manager exposes no option
      # for it (its compositor module covers input and workspaces, not
      # outputs). Set it in COSMIC Settings > Displays, then capture the
      # resulting file here via wayland.desktopManager.cosmic.stateFile if it
      # should be reproducible.
      interface_density = { __type = "enum"; variant = "Compact"; };
      header_size = { __type = "enum"; variant = "Compact"; };

      interface_font = {
        family = sharedFonts.generalFamily;
        stretch = { __type = "enum"; variant = "Normal"; };
        style = { __type = "enum"; variant = "Normal"; };
        weight = { __type = "enum"; variant = "Normal"; };
      };
      monospace_font = {
        family = sharedFonts.monoFamily;
        stretch = { __type = "enum"; variant = "Normal"; };
        style = { __type = "enum"; variant = "Normal"; };
        weight = { __type = "enum"; variant = "Normal"; };
      };
    };
  };
}
