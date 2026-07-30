# MacBook Pro 14", M1 Pro. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro14-m1-pro
{ inputs, ... }: {
  networking.hostName = "macbookpro14-m1-pro";
  networking.computerName = "macbookpro14-m1-pro";
  networking.localHostName = "macbookpro14-m1-pro";

  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/darwin/casks.nix
    ../../modules/darwin/hardware-macbookpro14.nix
  ];
}