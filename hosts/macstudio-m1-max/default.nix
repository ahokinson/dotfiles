# Mac Studio, M1 Max. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macstudio-m1-max
{ selfPath, ... }: {
  networking.hostName = "macstudio-m1-max";

  imports = [
    (selfPath "hosts/darwin-common.nix")
    (selfPath "modules/darwin/universalaccess.nix")
    (selfPath "modules/darwin/hardware-macstudio.nix")
  ];
}
