# macstudio-m1-max only. home/darwin/podman.nix only starts the podman
# machine on `home-manager switch`, never at boot - this LaunchDaemon
# closes that gap.
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
  launchd.daemons.podman-machine-boot = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.writeShellScript "podman-machine-boot" ''
          export PATH="${
            pkgs.lib.makeBinPath [
              pkgs.podman
              pkgs.openssh
            ]
          }:$PATH"
          if [[ "$(podman machine inspect podman-machine-default --format '{{.State}}' 2>/dev/null)" != "running" ]]; then
            podman machine start
          fi
        ''}"
      ];
      UserName = username;
      EnvironmentVariables.HOME = homeDir;
      RunAtLoad = true;
      StartInterval = 300; # one-shot check-and-start, so poll rather than KeepAlive
      StandardOutPath = "${homeDir}/Library/Logs/podman-machine-boot.log";
      StandardErrorPath = "${homeDir}/Library/Logs/podman-machine-boot.log";
    };
  };

  # gvproxy, not open-webui, is what actually listens on the LAN-facing
  # port - it's nix-built/ad-hoc-signed, which the Application Firewall
  # can silently block or prompt for.
  system.activationScripts.postActivation.text = ''
    /usr/libexec/ApplicationFirewall/socketfilterfw --add ${pkgs.gvproxy}/bin/gvproxy || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp ${pkgs.gvproxy}/bin/gvproxy || true
  '';
}
