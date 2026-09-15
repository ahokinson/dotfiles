{ pkgs, ... }: {
  # Fullscreen by default; never added to an idle hook. Each desktop has an
  # explicit shortcut of its own (Linux) or through skhd (macOS).
  home.packages = [ pkgs.lifesaver ];
}
