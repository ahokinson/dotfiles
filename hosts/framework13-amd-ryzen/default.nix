# Top-level NixOS host configuration. Assembles the modular system config
# and wires home-manager (common profile) for user `anders`.
# Hostname reflects the underlying hardware: Framework Laptop 13 with AMD
# Ryzen AI 7 350 (Ryzen AI 300 / "Strix Point" generation, A7 board version).
# Apply with: nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen
{
  inputs,
  selfPath,
  username,
  ...
}:
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
    (selfPath "modules/nixos/audio.nix")
    (selfPath "modules/nixos/boot.nix")
    (selfPath "modules/nixos/clamav.nix")
    (selfPath "modules/nixos/containers.nix")
    (selfPath "modules/nixos/desktop-cosmic.nix")
    (selfPath "modules/nixos/hermes.nix")
    (selfPath "modules/nixos/locale.nix")
    (selfPath "modules/nixos/networking.nix")
    (selfPath "modules/nixos/packages.nix")
    (selfPath "modules/nixos/printing.nix")
    (selfPath "modules/nixos/security.nix")
    (selfPath "modules/nixos/settings.nix")
    (selfPath "modules/nixos/ssh.nix")
    (selfPath "modules/nixos/user.nix")
    inputs.hermes-agent.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.${username} = {
      imports = [
        (selfPath "home/common")
        (selfPath "home/linux")
        (selfPath "home/linux/cosmic")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.zen-browser.homeModules.beta
      ];
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs selfPath; };
  };

  system.stateVersion = "26.05";
}
