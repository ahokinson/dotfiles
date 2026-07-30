# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ inputs, ... }: {
  networking.hostName = "macbookpro16-m5";
  networking.computerName = "macbookpro16-m5";
  networking.localHostName = "macbookpro16-m5";

  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/darwin/casks.nix
    ../../modules/darwin/hardware-macbookpro16.nix
  ];
}