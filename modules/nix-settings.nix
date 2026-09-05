# Shared between NixOS and Darwin: imported by modules/nixos/settings.nix
# and modules/darwin/system/settings.nix, which between them reach every
# host (including the Pi hosts, which import modules/nixos/settings.nix
# directly rather than through hosts/nixos-common.nix).
_: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
}
