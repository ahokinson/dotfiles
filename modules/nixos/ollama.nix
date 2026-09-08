# studio-m1-max only.
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1"; # loopback - open-webui.nix is the only client
  };

  systemd.services.ollama.serviceConfig.Restart = "on-failure";
}
