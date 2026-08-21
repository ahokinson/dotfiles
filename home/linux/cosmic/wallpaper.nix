# Managed desktop wallpaper for COSMIC, framework13-only — the same solid
# Catppuccin Frappe base-color image used everywhere else in this repo
# (home/linux/wallpaper.nix for Plasma, macOS's own desktop background).
#
# Unlike Plasma (home/linux/plasma.nix), this doesn't need a
# programs.plasma-style desktopScript run at login: cosmic-manager writes
# cosmic-bg's config declaratively via wayland.desktopManager.cosmic.wallpapers
# (verified against cosmic-manager's modules/wallpapers.nix), the same
# plain-config-file mechanism panel.nix's favorites and theme.nix's
# appearance settings use, not a D-Bus call — so it should apply during
# `nixos-rebuild switch`'s home-manager activation same as those. Whether
# a running cosmic-bg actually reloads on a config-file change without a
# session restart is unconfirmed; check after first switch.
{ selfPath, ... }:
let
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
in
{
  wayland.desktopManager.cosmic.wallpapers = [
    {
      output = "all";
      source = {
        __type = "enum";
        variant = "Path";
        value = [ wallpaper ];
      };

      # None of the fields below have a real default in cosmic-manager's
      # wallpapers submodule (plain mkOption, not defaultNullOpts.mk* like
      # the panel/theme options), so all are mandatory once this list has an
      # entry. Values chosen to suit a single flat-color image, where
      # scaling/sampling/rotation are visually irrelevant:
      filter_by_theme = false;
      filter_method = { __type = "enum"; variant = "Lanczos"; };
      # Fixed image, so this is a required-but-unused field.
      rotation_frequency = 0;
      sampling_method = { __type = "enum"; variant = "Alphanumeric"; };
      # "Zoom" avoids Fit's extra offset-tuple payload; a solid-color image
      # looks identical under either scaling mode anyway.
      scaling_mode = { __type = "enum"; variant = "Zoom"; };
    }
  ];
}
