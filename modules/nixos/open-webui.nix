# studio-m1-max and framework13-amd-ryzen.
{
  config,
  pkgs,
  selfPath,
  ...
}:
let
  themeCss = import (selfPath "home/common/open-webui-theme.nix") { inherit pkgs selfPath; };
in
{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0"; # the one surface phones/iPads hit
    port = 8080; # fixed fleet-wide - same bookmarked URL either boot-side
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
      ENABLE_CHANNELS = "False";
      ENABLE_NOTES = "False";
      ENABLE_MEMORIES = "False";
    };
    openFirewall = true;
  };

  systemd.services.open-webui.serviceConfig = {
    Restart = "on-failure";
    # Shadows the frontend's custom.css - see home/common/open-webui-theme.nix.
    BindReadOnlyPaths = [
      "${themeCss}:${config.services.open-webui.package.frontend}/share/open-webui/static/custom.css"
    ];
  };
}
