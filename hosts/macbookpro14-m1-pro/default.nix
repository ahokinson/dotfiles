# MacBook Pro 14", M1 Pro. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro14-m1-pro
{ selfPath, ... }: {
  networking.hostName = "macbookpro14-m1-pro";
  networking.computerName = "macbookpro14-m1-pro";
  networking.localHostName = "macbookpro14-m1-pro";

  imports = [
    (selfPath "modules/darwin/system.nix")
    (selfPath "modules/darwin/universalaccess.nix")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hardware-macbookpro14.nix")
  ];
}
