# Everything identical across the Macs. The hardware module and the
# universalaccess opt-out stay in each host's own default.nix.
# localHostName already defaults to computerName upstream.
{ selfPath, config, ... }:
{
  networking.computerName = config.networking.hostName;

  imports = [
    (selfPath "modules/darwin/system")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hermes.nix")
  ];
}
