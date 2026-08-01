# Mac Studio, M1 Max. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macstudio-m1-max
{ selfPath, ... }: {
  networking.hostName = "macstudio-m1-max";
  networking.computerName = "macstudio-m1-max";
  networking.localHostName = "macstudio-m1-max";

  imports = [
    (selfPath "modules/darwin/system.nix")
    (selfPath "modules/darwin/universalaccess.nix")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hardware-macstudio.nix")
    (selfPath "modules/darwin/hermes.nix")
  ];
}
