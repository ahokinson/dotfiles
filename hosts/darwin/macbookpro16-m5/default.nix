# MacBook Pro 16", M5. Apply with:
#   darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5
{ selfPath, ... }: {
  networking.hostName = "macbookpro16-m5";
  # MDM-managed work machine: keep personal-only apps off it.
  local.host.forWork = true;

  nix.settings.ssl-cert-file = "/etc/nix/ca-bundle.pem";

  imports = [
    (selfPath "hosts/darwin/common.nix")
    # No universalaccess.nix: MDM blocks that domain and aborts activation.
    (selfPath "modules/darwin/desktop/laptop-wake.nix")
    # If the MDM profile ends up blocking yabai's Accessibility permission
    # grant, drop this one line rather than touching yabai.nix itself.
    (selfPath "modules/darwin/services/yabai.nix")
  ];
}
