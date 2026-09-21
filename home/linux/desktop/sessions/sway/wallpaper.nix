# Picks the wallpaper by whether this host is Apple Silicon running Asahi
# (hostFacts.isApple, threaded via extraSpecialArgs same as selfPath).
#
# No hyprpaper-style daemon/workaround needed: Sway's own `output <name> bg`
# directive spawns swaybg itself as part of normal startup. swaybg is added
# explicitly to home.packages since home-manager's sway module doesn't pull
# it onto the wrapped binary's PATH on its own.
{
  pkgs,
  selfPath,
  hostFacts,
  ...
}:
let
  inherit (hostFacts) isApple;
  wallpaper = selfPath (
    if isApple then "home/common/assets/wallpaper/asahi.jpg" else "home/common/assets/wallpaper/nix.jpg"
  );
in
{
  home.packages = [ pkgs.swaybg ];

  wayland.windowManager.sway.extraConfig = ''
    output "*" bg ${wallpaper} fill
  '';
}
