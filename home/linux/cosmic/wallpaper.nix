# The same solid Frappe base-color image the Macs use. cosmic-manager writes
# cosmic-bg's config directly, so it applies at activation with no login-time
# script.
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

      # No field here has a default in cosmic-manager's wallpapers submodule,
      # so all are mandatory once the list is non-empty. Scaling, sampling and
      # rotation are moot for a flat-color image.
      filter_by_theme = false;
      filter_method = {
        __type = "enum";
        variant = "Lanczos";
      };
      rotation_frequency = 0;
      sampling_method = {
        __type = "enum";
        variant = "Alphanumeric";
      };
      scaling_mode = {
        __type = "enum";
        variant = "Zoom";
      };
    }
  ];
}
