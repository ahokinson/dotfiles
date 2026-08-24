# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ selfPath, ... }: {
  networking.hostName = "macbookpro16-m5";

  imports = [
    (selfPath "hosts/darwin-common.nix")
    # No modules/darwin/universalaccess.nix here: this is a work-managed
    # laptop and an MDM profile blocks writes to com.apple.universalaccess,
    # which aborts activation.
    (selfPath "modules/darwin/hardware-macbookpro16.nix")
  ];
}
