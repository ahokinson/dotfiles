# studio-m1-max and framework13-amd-ryzen. ollama-vulkan over ollama-rocm
# even on the Framework's AMD iGPU - RADV needs no rocmOverrideGfx fussing,
# and it's the only option on the Studio's Asahi driver anyway.
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # loopback - open-webui.nix is the only client
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
