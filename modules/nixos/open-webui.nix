# studio-m1-max only.
{ config, ... }:
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

  systemd.services.open-webui.serviceConfig.Restart = "on-failure";
}
