{
  config,
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  themeCss = import (selfPath "home/common/apps/ai/open-webui/theme.nix") { inherit pkgs selfPath; };

  # Model settings that only exist as Open WebUI's DB-backed model metadata,
  # not an env var - not a PersistentConfig setting, so ENABLE_PERSISTENT_CONFIG
  # doesn't reset them, and they're safe to (re-)apply on every boot. Extend
  # this attrset for other such settings; the service below stays generic.
  openWebuiModelDefaults = {
    meta.capabilities.builtin_tools = false; # attached to every request otherwise; local models without tool-call training reject it outright.
    params = { };
    access_grants = [
      {
        resource_type = "model";
        principal_type = "user";
        principal_id = "*"; # public - BYPASS_MODEL_ACCESS_CONTROL doesn't exist in current open-webui, this is the real mechanism.
        permission = "read";
      }
    ];
  };

  openWebuiModelPayload =
    id:
    builtins.toJSON (
      openWebuiModelDefaults
      // {
        inherit id;
        name = id;
      }
    );
in
{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 6604;
    environment = {
      ANONYMIZED_TELEMETRY = "false";
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

  # WEBUI_AUTH=False means sign-in always resolves to this same fixed,
  # hardcoded admin@localhost/admin pair - not a secret to protect.
  systemd.services.open-webui-model-settings = {
    after = [ "open-webui.service" ];
    wants = [ "open-webui.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      base="http://127.0.0.1:${toString config.services.open-webui.port}"

      until curl -sf "$base/health" >/dev/null; do sleep 1; done

      token=$(curl -sf -X POST "$base/api/v1/auths/signin" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@localhost","password":"admin"}' \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

      ${lib.concatMapStringsSep "\n" (id: ''
        payload=${lib.escapeShellArg (openWebuiModelPayload id)}
        curl -sf -X POST "$base/api/v1/models/create" \
          -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
          -d "$payload" >/dev/null \
        || curl -sf -X POST "$base/api/v1/models/model/update" \
          -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
          -d "$payload" >/dev/null
      '') config.services.ollama.loadModels}
    '';
  };
}
