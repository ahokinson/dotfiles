# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ selfPath, ... }: {
  networking.hostName = "macbookpro16-m5";

  imports = [
    (selfPath "hosts/darwin-common.nix")
    # No universalaccess.nix: MDM blocks that domain and aborts activation.
    (selfPath "modules/darwin/hardware-macbookpro16.nix")
  ];
}
