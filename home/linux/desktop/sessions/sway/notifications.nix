# cosmic-notifications is bundled into cosmic-session; mako is the
# wlroots-ecosystem equivalent. No systemd unit of its own - D-Bus-activated
# on the first notification.
{ selfPath, ... }:
let
  palette = import (selfPath "home/common/theme/palette.nix");
in
{
  catppuccin.mako.accent = "blue"; # match compositor.nix's blue border override
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
      anchor = "top-right";
      # 0.867 (hex dd) matches fuzzel's own shipped alpha - repo-wide
      # frosted-glass consistency.
      background-color = "${palette.base}dd";
    };
  };
}
