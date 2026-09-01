# Top-level NixOS host configuration. Hostname reflects the underlying
# hardware: Framework Laptop 13 with AMD Ryzen AI 7 350 (Ryzen AI 300 /
# "Strix Point" generation, A7 board version). Everything this shares with the
# other NixOS hosts lives in hosts/nixos-common.nix; what is left below is
# what this board actually forces.
# Apply with: nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen
{ inputs, selfPath, ... }:
{
  networking.hostName = "framework13-amd-ryzen";

  imports = [
    # Framework 13 with a Ryzen AI 300-series board. Brings fwupd for EC and
    # BIOS firmware, fprintd for the fingerprint reader, the framework-laptop
    # kmod (sysfs access to the embedded controller) and framework_tool,
    # fstrim, and the snd_acp70 blacklist that works around the BIOS
    # mis-reporting the ACP device as wired.
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    (selfPath "hosts/framework13-amd-ryzen/hardware-configuration.nix")
    (selfPath "hosts/nixos-common.nix")
  ];

  # Without this plymouth comes up on the EFI framebuffer through simpledrm and
  # gets resized a second later when amdgpu takes the panel over. Loading the
  # driver in the initrd means the splash is drawn once, at the native mode.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # This board's MT7925 drops the link intermittently across suspend/resume
  # with power save on. Scoped to this host rather than to
  # modules/nixos/networking.nix: the Asahi machines run Broadcom (brcmfmac),
  # which is also why they pick a different NetworkManager backend, so the
  # workaround has nothing to do there.
  networking.networkmanager.wifi.powersave = false;
}
