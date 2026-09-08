# macstudio-m1-max only. No darwin/home-manager module ships ollama, so
# this hand-rolls the launchd equivalent, same as modules/darwin/hermes.nix.
# A LaunchDaemon, not a LaunchAgent: it must keep serving across an
# unattended reboot, not just once someone's logged in.
{
  pkgs,
  config,
  username,
  ...
}:
let
  homeDir = config.users.users.${username}.home;
in
{
  launchd.daemons.ollama = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      UserName = username;
      EnvironmentVariables.HOME = homeDir;
      WorkingDirectory = homeDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${homeDir}/Library/Logs/ollama.log";
      StandardErrorPath = "${homeDir}/Library/Logs/ollama.log";
    };
  };
}
