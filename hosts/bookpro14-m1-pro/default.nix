# MacBook Pro 14", M1 Pro, on bare metal via nixos-apple-silicon. The rest is
# in hosts/asahi-common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#bookpro14-m1-pro --impure
{ selfPath, ... }:
{
  networking.hostName = "bookpro14-m1-pro";

  imports = [
    (selfPath "hosts/bookpro14-m1-pro/hardware-configuration.nix")
    (selfPath "hosts/asahi-common.nix")
    (selfPath "modules/nixos/nas-mount.nix")
  ];

  # 3024x1890 built-in panel (card1-eDP-1), not the 1504 default.
  local.splash.panelHeightPx = 1890;
}
