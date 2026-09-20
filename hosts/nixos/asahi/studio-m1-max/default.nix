# Mac Studio, M1 Max, on bare metal via nixos-apple-silicon. The rest is in
# hosts/nixos/asahi/common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#studio-m1-max --impure
{ selfPath, ... }:
{
  networking.hostName = "studio-m1-max";

  imports = [
    (selfPath "hosts/nixos/asahi/studio-m1-max/hardware-configuration.nix")
    (selfPath "hosts/nixos/asahi/common.nix")
    (selfPath "modules/nixos/networking/nas-mount.nix")
    (selfPath "modules/nixos/services/ollama.nix")
    (selfPath "modules/nixos/services/open-webui.nix")
  ];
}
