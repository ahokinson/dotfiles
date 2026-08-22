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
      # Extends the Catppuccin/COSMIC theme to non-COSMIC GTK apps too,
      # instead of them falling back to their own GTK theme - one look
      # across the session rather than COSMIC apps only.
      apply_theme_global = true;

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
