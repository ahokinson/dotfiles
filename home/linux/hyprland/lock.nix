# Same wallpaper selection as wallpaper.nix and home/linux/cosmic/wallpaper.nix -
# each file re-derives isApple from home/common/host.nix independently rather
# than sharing one binding, matching the existing cosmic/ convention.
{
  selfPath,
  osConfig ? null,
  ...
}:
let
  isApple = (import (selfPath "home/common/host.nix") { inherit osConfig; }).isApple;
  wallpaper = selfPath (
    if isApple then "home/common/_files/wallpaper/asahi.jpg" else "home/common/_files/wallpaper/nix.jpg"
  );
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "${wallpaper}";
          blur_passes = 2;
        }
      ];
      input-field = [
        {
          size = "250, 60";
          outline_thickness = 2;
        }
      ];
    };
  };
}
