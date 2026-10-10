# studio-m1-max and framework13-amd-ryzen. ollama-vulkan over ollama-rocm
# even on the Framework's AMD iGPU - RADV needs no rocmOverrideGfx fussing,
# and it's the only option on the Studio's Asahi driver anyway.
{ pkgs, selfPath, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # loopback - open-webui.nix is the only client
    environmentVariables = {
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
    loadModels = builtins.attrNames (import (selfPath "modules/nixos/services/models.nix"));
    syncModels = true;
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
