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
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hermes.nix")
    (selfPath "modules/darwin/sleep.nix")
  ];

  # Set by the work host to drop personal-only apps. home-manager modules
  # read it via osConfig (home/common/host.nix), not through specialArgs.
  options.forWork = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config.networking.computerName = config.networking.hostName;
}
