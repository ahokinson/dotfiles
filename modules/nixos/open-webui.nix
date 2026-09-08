# studio-m1-max only.
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
    host = "0.0.0.0";
    port = 8080;
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
