# Mac Studio, M1 Max, on bare metal via nixos-apple-silicon. The rest is in
# hosts/asahi-common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#studio-m1-max --impure
{ selfPath, ... }:
{
  networking.hostName = "studio-m1-max";

  imports = [
    (selfPath "hosts/studio-m1-max/hardware-configuration.nix")
    (selfPath "hosts/asahi-common.nix")
    (selfPath "modules/nixos/nas-mount.nix")
  ];
}
