# Shared by every darwin host: computerName/localHostName mirror
# networking.hostName (set per-host), plus the imports every Mac gets
# regardless of hardware. Host-specific bits (hardware module,
# universalaccess.nix opt-out) stay in each host's own default.nix.
{ selfPath, config, ... }:
{
  networking.computerName = config.networking.hostName;
  networking.localHostName = config.networking.hostName;

  imports = [
    (selfPath "modules/darwin/system")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hermes.nix")
  ];
}
