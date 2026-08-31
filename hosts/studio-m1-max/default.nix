# Top-level NixOS host configuration. Hostname reflects the underlying
# hardware: Mac Studio, M1 Max, running NixOS bare metal via
# nixos-apple-silicon (dual-boots macOS). Shared Asahi config lives in
# hosts/asahi-common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#studio-m1-max --impure
{ selfPath, ... }:
{
  networking.hostName = "studio-m1-max";

  imports = [
    (selfPath "hosts/studio-m1-max/hardware-configuration.nix")
    (selfPath "hosts/asahi-common.nix")
  ];
}
