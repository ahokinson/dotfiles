# MacBook Pro 14", M1 Pro. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro14-m1-pro
{ selfPath, ... }: {
  networking.hostName = "macbookpro14-m1-pro";

  imports = [
    (selfPath "hosts/darwin-common.nix")
    (selfPath "modules/darwin/universalaccess.nix")
    (selfPath "modules/darwin/laptop-wake.nix")
  ];
}
