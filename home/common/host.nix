# Facts about this host, read off osConfig - the outer NixOS/nix-darwin
# config - so home-manager modules can branch on them. Both default safely
# when there's no outer config to ask.
{ osConfig ? null }: {
  # Whether this NixOS host is Apple Silicon hardware running Asahi, as
  # opposed to framework13-amd-ryzen.
  isApple = osConfig.hardware.asahi.enable or false;

  # Whether this Mac is the MDM-managed work machine, as opposed to a
  # personal one. NixOS hosts never declare a forWork option, so this
  # doubles as their default.
  forWork = osConfig.forWork or false;
}
