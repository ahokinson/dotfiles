# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ selfPath, ... }: {
  networking.hostName = "macbookpro16-m5";
  networking.computerName = "macbookpro16-m5";
  networking.localHostName = "macbookpro16-m5";

  imports = [
    (selfPath "modules/darwin/system.nix")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hardware-macbookpro16.nix")
  ];
}
