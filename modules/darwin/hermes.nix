# The upstream hermes-agent flake ships only a NixOS systemd module, so this
# hand-rolls the launchd equivalent of modules/nixos/hermes.nix. Per-user,
# against ~/.hermes as populated by home/common/hermes/default.nix.
{ pkgs, config, username, ... }:
let
  homeDir = config.users.users.${username}.home;
in
{
  launchd.agents.hermes-agent = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.hermes}/bin/hermes"
        "gateway"
      ];
      EnvironmentVariables = {
        HOME = homeDir;
        HERMES_HOME = "${homeDir}/.hermes";
        HERMES_MANAGED = "true";
      };
      WorkingDirectory = homeDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${homeDir}/Library/Logs/hermes-agent.log";
      StandardErrorPath = "${homeDir}/Library/Logs/hermes-agent.log";
    };
  };
}
