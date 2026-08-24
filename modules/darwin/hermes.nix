# Darwin equivalent of modules/nixos/hermes.nix. The upstream hermes-agent
# flake (NousResearch/hermes-agent) only ships a NixOS systemd module, so
# this hand-rolls a launchd agent running the same `hermes gateway` command
# its systemd ExecStart uses (`pkgs.hermes` is that same package, aliased by
# inputs.flake's overlay in overlays/default.nix). Runs as a per-user
# LaunchAgent against the user's own ~/.hermes (already populated by
# home/common/hermes/default.nix), not the NixOS module's isolated system
# user/stateDir, since a personal Mac has no need for that isolation.
{ pkgs, username, ... }:
let
  homeDir = "/Users/${username}";
in {
  launchd.agents.hermes-agent = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.hermes}/bin/hermes" "gateway" ];
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
