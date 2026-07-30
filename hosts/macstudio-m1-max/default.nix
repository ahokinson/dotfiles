# Mac Studio, M1 Max. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macstudio-m1-max
{ inputs, ... }: {
  networking.hostName = "macstudio-m1-max";
  networking.computerName = "macstudio-m1-max";
  networking.localHostName = "macstudio-m1-max";

  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/darwin/casks.nix
    ../../modules/darwin/hardware-macstudio.nix
  ];
}