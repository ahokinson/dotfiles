# macstudio-m1-max only. Runs Open WebUI as the official container, not
# pkgs.open-webui - a heavy torch/onnxruntime build, real risk on darwin.
{
  pkgs,
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.networking.hostName == "macstudio-m1-max") {
  home.activation.openWebuiContainer = lib.hm.dag.entryAfter [ "podmanMachine" ] ''
    export PATH="${lib.makeBinPath [ pkgs.podman ]}:$PATH"
    if ! podman container exists open-webui; then
      run podman run -d --name open-webui --restart=always \
        -p 8080:8080 \
        -e OLLAMA_API_BASE_URL=http://host.containers.internal:11434 \
        -e OPENAI_API_BASE_URLS=http://host.containers.internal:8081/v1 \
        -e OPENAI_API_KEYS=not-needed \
        -v open-webui:/app/backend/data \
        ghcr.io/open-webui/open-webui:0.11.3
    fi
  '';
}
