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
      "hf.co/unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M"
      "hf.co/dphn/Dolphin-X1-Trinity-Nano-GGUF:Q4_K_M"
      "hf.co/NousResearch/Hermes-4.3-36B-GGUF:Q4_K_M"
      "hf.co/unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q4_K_M"
      "hf.co/unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q4_K_M"
    ];
    syncModels = true;
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
