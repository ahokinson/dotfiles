# cosmic-notifications is bundled into cosmic-session; mako is the
# wlroots-ecosystem equivalent. No systemd unit of its own - D-Bus-activated
# on the first notification.
{
  catppuccin.mako.accent = "blue"; # match compositor.nix/waybar.nix's blue override
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
      anchor = "top-right";
    };
  };
}
