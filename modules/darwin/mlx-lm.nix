# macstudio-m1-max only. Supervises the mlx_lm.server installed by
# home/darwin/mlx-lm.nix, serving raw Hugging Face models with Metal
# acceleration as a second OpenAI-compatible connection alongside ollama.
{ config, username, ... }:
let
  homeDir = config.users.users.${username}.home;
in
{
  launchd.daemons.mlx-lm-server = {
    serviceConfig = {
      ProgramArguments = [
        "${homeDir}/.local/bin/mlx_lm.server"
        "--model"
        "mlx-community/REPLACE-ME" # size to this Mac's unified memory
        "--host"
        "127.0.0.1"
        "--port"
        "8081"
      ];
      UserName = username;
      EnvironmentVariables.HOME = homeDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${homeDir}/Library/Logs/mlx-lm-server.log";
      StandardErrorPath = "${homeDir}/Library/Logs/mlx-lm-server.log";
    };
  };
}
