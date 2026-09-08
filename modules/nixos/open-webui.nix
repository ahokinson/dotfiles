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
      ENABLE_ADMIN_ANALYTICS = "False";
      ENABLE_AUTOMATIONS = "False";
      ENABLE_CALENDAR = "False";
      ENABLE_CHANNELS = "False";
      ENABLE_CODE_EXECUTION = "False";
      ENABLE_CODE_INTERPRETER = "False";
      ENABLE_COMMUNITY_SHARING = "False";
      ENABLE_EVALUATION_ARENA_MODELS = "False";
      ENABLE_FOLLOW_UP_GENERATION = "False";
      ENABLE_MEMORIES = "False";
      ENABLE_MESSAGE_RATING = "False";
      ENABLE_NOTES = "False";
      ENABLE_OAUTH = "False";
      ENABLE_RETRIEVAL_QUERY_GENERATION = "False";
      ENABLE_SEARCH_QUERY_GENERATION = "False";
      ENABLE_TAGS_GENERATION = "False";
      ENABLE_USER_STATUS = "False";
      ENABLE_VOICE_MODE_PROMPT = "False";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
      WEBUI_AUTH = "False";
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
