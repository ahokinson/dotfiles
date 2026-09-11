# The upstream hermes-agent flake ships only a NixOS systemd module, so this
# hand-rolls the launchd equivalent of modules/nixos/hermes.nix. Per-user,
# against ~/.hermes as populated by home/common/hermes/default.nix.
# hermes-agent is a personal always-on daemon, dropped on the work Mac; see
# home/common/default.nix for the home-manager half of this same gate.
{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  homeDir = config.users.users.${username}.home;
in
{
  config = lib.mkIf (!config.forWork) {
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
  };
}
