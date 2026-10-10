{ selfPath, ... }:
{
  imports = [
    (selfPath "modules/nixos/services/ollama.nix")
    (selfPath "modules/nixos/services/open-webui.nix")
  ];
}
