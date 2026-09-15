# cosmic-osd draws the volume/brightness popups on COSMIC; swayosd is the
# wlroots-ecosystem equivalent. compositor.nix's XF86 binds call
# swayosd-client instead of raw wpctl/brightnessctl. Its udev rule is added
# in modules/nixos/desktop/sway.nix's services.udev.packages.
{
  services.swayosd.enable = true;
}
