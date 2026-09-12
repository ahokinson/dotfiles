# Same wallpaper selection as lock.nix and home/linux/cosmic/wallpaper.nix -
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
  services.hyprpaper = {
    enable = true;

    # package = null keeps this module generating hyprpaper.conf below
    # without its own systemd unit, which binds to graphical-session.target
    # by default - reached via hyprland-session.target's BindsTo, but that
    # chain never reliably completed here (see waybar.nix). compositor.nix
    # execs the pkgs.hyprpaper it adds to home.packages directly instead.
    package = null;

    # hyprpaper 0.8.4 has no "preload" directive and "wallpaper" is a
    # category block (monitor/path/fit_mode/...), not the classic flat
    # "preload=path" + "wallpaper=,path" pair every tutorial online still
    # shows - confirmed against src/config/{ConfigManager,WallpaperMatcher}.cpp
    # at the v0.8.4 tag. monitor = "" is a documented wildcard (isWildcard()
    # treats empty string or "*" as every monitor).
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "${wallpaper}";
        }
      ];
    };
  };
}
