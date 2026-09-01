# Framework Laptop 13, AMD Ryzen AI 7 350 ("Strix Point", A7 board). Only
# what this board forces; the rest is in hosts/nixos-common.nix.
# Apply with: nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen
{ inputs, selfPath, ... }:
{
  networking.hostName = "framework13-amd-ryzen";

  imports = [
    # Brings fwupd, fprintd, the framework-laptop kmod and framework_tool,
    # fstrim, and the snd_acp70 blacklist for the BIOS mis-reporting the ACP
    # device as wired.
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    (selfPath "hosts/framework13-amd-ryzen/hardware-configuration.nix")
    (selfPath "hosts/nixos-common.nix")
  ];

  # Otherwise plymouth starts on the EFI framebuffer via simpledrm and is
  # resized a second later when amdgpu takes the panel. In the initrd, the
  # splash is drawn once, at the native mode.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # This board's MT7925 drops the link across suspend/resume with power save
  # on. Host-scoped: the Asahi machines run brcmfmac and are unaffected.
  networking.networkmanager.wifi.powersave = false;
}
