# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ selfPath, username, ... }: {
  networking.hostName = "macbookpro16-m5";
  # MDM-managed work machine: keep personal-only apps off it.
  forWork = true;

  # Cato VPN TLS-inspects HTTPS traffic; Nix's own cacert bundle doesn't
  # trust its CA even though the system keychain does. Point Nix at the
  # combined bundle IT provides instead of the nixpkgs default.
  nix.settings.ssl-cert-file = "/Users/${username}/.reggora/certs/ssl-ca-bundle.pem";

  imports = [
    (selfPath "hosts/darwin/common.nix")
    # No universalaccess.nix: MDM blocks that domain and aborts activation.
    (selfPath "modules/darwin/desktop/laptop-wake.nix")
  ];
}
