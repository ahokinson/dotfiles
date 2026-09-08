# Mac Studio, M1 Max, on bare metal via nixos-apple-silicon. The rest is in
# hosts/asahi-common.nix.
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#studio-m1-max --impure
{ selfPath, ... }:
{
  networking.hostName = "studio-m1-max";

  imports = [
    (selfPath "hosts/studio-m1-max/hardware-configuration.nix")
    (selfPath "hosts/asahi-common.nix")
    (selfPath "modules/nixos/nas-mount.nix")
    (selfPath "modules/nixos/ollama.nix")
    (selfPath "modules/nixos/open-webui.nix")
  ];

  # 64GB of RAM here vs. 32GB on the Framework - room for a bigger model
  # than the shared list in modules/nixos/ollama.nix declares.
  services.ollama.loadModels = [
    "hf.co/NousResearch/Hermes-4.3-36B-GGUF:Q4_K_M"
  ];
}
