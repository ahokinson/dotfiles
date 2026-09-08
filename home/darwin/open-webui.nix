# macstudio-m1-max only. Runs Open WebUI as the official container, not
# pkgs.open-webui - a heavy torch/onnxruntime build, real risk on darwin.
# -slim skips pre-baking the sentence-transformers/whisper/tiktoken model
# weights - unused here, chat-only, no local RAG/STT. ENABLE_*/WEBUI_AUTH
# match modules/nixos/open-webui.nix.
{
  pkgs,
  lib,
  osConfig,
  selfPath,
  ...
}:
let
  themeCss = import (selfPath "home/common/open-webui-theme.nix") { inherit pkgs selfPath; };
in
lib.mkIf (osConfig.networking.hostName == "macstudio-m1-max") {
  home.activation.openWebuiContainer = lib.hm.dag.entryAfter [ "podmanMachine" ] ''
    export PATH="${lib.makeBinPath [ pkgs.podman ]}:$PATH"

    # The Nix store isn't visible inside the podman machine VM - copy the
    # theme to a path it can see, then bind that in below.
    run mkdir -p "$HOME/.config/open-webui"
    run install -m644 ${themeCss} "$HOME/.config/open-webui/custom.css"

    if ! podman container exists open-webui; then
      run podman run -d --name open-webui --restart=always \
        -p 8080:8080 \
        -e ENABLE_ADMIN_ANALYTICS=False \
        -e ENABLE_AUTOMATIONS=False \
        -e ENABLE_CALENDAR=False \
        -e ENABLE_CHANNELS=False \
        -e ENABLE_CODE_EXECUTION=False \
        -e ENABLE_CODE_INTERPRETER=False \
        -e ENABLE_COMMUNITY_SHARING=False \
        -e ENABLE_EVALUATION_ARENA_MODELS=False \
        -e ENABLE_FOLLOW_UP_GENERATION=False \
        -e ENABLE_MEMORIES=False \
        -e ENABLE_MESSAGE_RATING=False \
        -e ENABLE_NOTES=False \
        -e ENABLE_OAUTH=False \
        -e ENABLE_RETRIEVAL_QUERY_GENERATION=False \
        -e ENABLE_SEARCH_QUERY_GENERATION=False \
        -e ENABLE_TAGS_GENERATION=False \
        -e ENABLE_USER_STATUS=False \
        -e ENABLE_VOICE_MODE_PROMPT=False \
        -e OLLAMA_API_BASE_URL=http://host.containers.internal:11434 \
        -e OPENAI_API_BASE_URLS=http://host.containers.internal:8081/v1 \
        -e OPENAI_API_KEYS=not-needed \
        -e WEBUI_AUTH=False \
        -v open-webui:/app/backend/data \
        -v "$HOME/.config/open-webui/custom.css:/app/build/static/custom.css:ro" \
        ghcr.io/open-webui/open-webui:0.11.3-slim
    fi
  '';
}
