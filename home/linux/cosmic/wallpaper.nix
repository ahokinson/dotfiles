# The same tower, submerged: home/darwin/wallpaper.nix uses the dry, lit
# version for real macOS. Both are NixOS on Apple hardware, so isApple here
# means Asahi specifically.
# cosmic-manager writes cosmic-bg's config directly, so it applies at
# activation with no login-time script.
{
  selfPath,
  osConfig ? null,
  ...
}:
let
  isApple = import (selfPath "home/common/is-apple.nix") { inherit osConfig; };
  wallpaper = selfPath (
    if isApple then "home/common/_files/wallpaper/asahi.jpg" else "home/common/_files/wallpaper/nix.jpg"
  );
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
      # so all are mandatory once the list is non-empty.
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
