# Top-level NixOS host configuration. Hostname reflects the underlying
# hardware: MacBook Pro 14", M1 Pro, running NixOS bare metal via
# nixos-apple-silicon (dual-boots macOS). Shared Asahi config lives in
# hosts/asahi-common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#bookpro14-m1-pro --impure
{ selfPath, ... }:
{
  networking.hostName = "bookpro14-m1-pro";

  imports = [
    (selfPath "hosts/bookpro14-m1-pro/hardware-configuration.nix")
    (selfPath "hosts/asahi-common.nix")
  ];

  # 3024x1890 built-in panel (card1-eDP-1), well above the 1504 this defaults
  # to, so modules/nixos/splash.nix scales the Nix mark up to match.
  local.splash.panelHeightPx = 1890;
}
