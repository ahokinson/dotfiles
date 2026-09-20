# studio-m1-max and framework13-amd-ryzen. ollama-vulkan over ollama-rocm
# even on the Framework's AMD iGPU - RADV needs no rocmOverrideGfx fussing,
# and it's the only option on the Studio's Asahi driver anyway.
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # loopback - open-webui.nix is the only client
    loadModels = [
      "hf.co/Qwen/Qwen3-30B-A3B-GGUF:Q4_K_M"
      "hf.co/Qwen/Qwen3-8B-GGUF:Q4_K_M"
      "hf.co/NousResearch/Hermes-4.3-36B-GGUF:Q4_K_M"
      "hf.co/unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q4_K_M"
    ];
    syncModels = true;
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
