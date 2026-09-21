# studio-m1-max and framework13-amd-ryzen. ollama-vulkan over ollama-rocm
# even on the Framework's AMD iGPU - RADV needs no rocmOverrideGfx fussing,
# and it's the only option on the Studio's Asahi driver anyway.
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # loopback - open-webui.nix is the only client
    environmentVariables = {
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
    loadModels = [
      "hf.co/bartowski/Dolphin3.0-Llama3.2-3B-GGUF:Q5_K_M"
      "hf.co/bartowski/NousResearch_Hermes-4-14B-GGUF:Q5_K_M"
      "hf.co/unsloth/DeepSeek-R1-Distill-Qwen-14B-GGUF:Q5_K_M"
      "hf.co/unsloth/gemma-4-12b-it-GGUF:Q5_K_M"
      "hf.co/unsloth/Qwen3.5-4B-GGUF:Q5_K_M"
    ];
    syncModels = true;
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
