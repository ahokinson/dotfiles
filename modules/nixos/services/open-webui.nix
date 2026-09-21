{
  config,
  pkgs,
  selfPath,
  ...
}:
let
  themeCss = import (selfPath "home/common/apps/ai/open-webui/theme.nix") { inherit pkgs selfPath; };
in
{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 6604;
    environment = {
      ANONYMIZED_TELEMETRY = "false";
      BYPASS_MODEL_ACCESS_CONTROL = "True";
      DEFAULT_PROMPT_SUGGESTIONS = builtins.toJSON [
        {
          title = [
            ""
            ""
          ];
          content = "";
        }
      ];
      DO_NOT_TRACK = "true";
      ENABLE_ADMIN_ANALYTICS = "False";
      ENABLE_ADMIN_CHAT_ACCESS = "False";
      ENABLE_ADMIN_EXPORT = "False";
      ENABLE_ADMIN_WORKSPACE_CONTENT_ACCESS = "False";
      ENABLE_AUTOMATIONS = "False";
      ENABLE_CALENDAR = "False";
      ENABLE_CHANNELS = "False";
      ENABLE_CODE_EXECUTION = "False";
      ENABLE_CODE_INTERPRETER = "False";
      ENABLE_COMMUNITY_SHARING = "False";
      ENABLE_EVALUATION_ARENA_MODELS = "False";
      ENABLE_FOLDERS = "False";
      ENABLE_FOLLOW_UP_GENERATION = "False";
      ENABLE_LOGIN_FORM = "False";
      ENABLE_MEMORIES = "False";
      ENABLE_MESSAGE_RATING = "False";
      ENABLE_NOTES = "False";
      ENABLE_OAUTH = "False";
      ENABLE_OPENAI_API = "False";
      ENABLE_PERSISTENT_CONFIG = "False";
      ENABLE_RETRIEVAL_QUERY_GENERATION = "False";
      ENABLE_SEARCH_QUERY_GENERATION = "False";
      ENABLE_SIGNUP = "False";
      ENABLE_SUBAGENTS = "False";
      ENABLE_TAGS_GENERATION = "False";
      ENABLE_TITLE_GENERATION = "False";
      ENABLE_USER_STATUS = "False";
      ENABLE_USER_WEBHOOKS = "False";
      ENABLE_VERSION_UPDATE_CHECK = "False";
      ENABLE_VOICE_MODE_PROMPT = "False";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
      SCARF_NO_ANALYTICS = "true";
      SUBAGENTS_BACKGROUND_ENABLED = "False";
      USER_PERMISSIONS_CHAT_TEMPORARY_ENFORCED = "True";
      WEBUI_AUTH = "False";
    };
    openFirewall = true;
  };

  systemd.services.open-webui.serviceConfig = {
    Restart = "on-failure";
    BindReadOnlyPaths = [
      "${themeCss}:${config.services.open-webui.package.frontend}/share/open-webui/static/custom.css"
    ];
  };
}
