# LifeSaver is the deliberate fullscreen idle display. Do not have Hyprland
# lock, blank the outputs, or suspend underneath it. This applies equally on
# AC and battery so both power modes behave the same.
{
  services.hypridle = {
    enable = false;
  };
}
