# Shared by every darwin host: computerName mirrors networking.hostName (set
# per-host; localHostName already defaults to it upstream), plus the imports
# every Mac gets regardless of hardware. Host-specific bits (hardware module,
# universalaccess.nix opt-out) stay in each host's own default.nix.
{ selfPath, config, ... }:
{
  networking.computerName = config.networking.hostName;

  imports = [
    (selfPath "modules/darwin/system")
    (selfPath "modules/darwin/home-manager.nix")
    (selfPath "modules/darwin/hermes.nix")
  ];
}
