# Everything identical across the Macs. The hardware module and the
# universalaccess opt-out stay in each host's own default.nix.
# localHostName already defaults to computerName upstream.
{
  selfPath,
  config,
  lib,
  ...
}:
{
  imports = [
    (selfPath "modules/darwin/system")
    (selfPath "modules/darwin/user/home-manager.nix")
    (selfPath "modules/darwin/services/hermes.nix")
    (selfPath "modules/darwin/desktop/idle.nix")
  ];

  # Set by the work host to drop personal-only apps. home-manager modules
  # read it via hostFacts.forWork (home/common/lib/host.nix, threaded through
  # extraSpecialArgs), not through this option directly.
  options.local.host.forWork = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether this Mac is the MDM-managed work machine.";
  };

  config.networking.computerName = config.networking.hostName;
}
