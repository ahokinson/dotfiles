# Managed desktop wallpaper for COSMIC, framework13-only — the same solid
# Catppuccin Frappe base-color image used everywhere else in this repo.
# cosmic-manager writes cosmic-bg's config declaratively (verified against
# its modules/wallpapers.nix), the same plain-config-file mechanism
# panel.nix and theme.nix use, so it applies during home-manager activation
# rather than needing the login-time script Plasma's own wallpaper handling
# uses.
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

      # None of these fields have a real default in cosmic-manager's
      # wallpapers submodule, so all are mandatory once this list has an
      # entry. Values chosen to suit a single flat-color image, where
      # scaling/sampling/rotation are visually irrelevant.
      filter_by_theme = false;
      filter_method = { __type = "enum"; variant = "Lanczos"; };
      rotation_frequency = 0;
      sampling_method = { __type = "enum"; variant = "Alphanumeric"; };
      scaling_mode = { __type = "enum"; variant = "Zoom"; };
    }
  ];
}
