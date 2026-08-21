# Top-level NixOS host configuration — assembles the modular system config
# and wires home-manager (common profile) for user `anders`.
# Hostname reflects the underlying hardware: Framework Laptop 13 with AMD
# Ryzen AI 7 350 (Ryzen AI 300 / "Strix Point" generation, A7 board version).
# Apply with: nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen
{ inputs, selfPath, pkgs, lib, ... }:
{
  networking.hostName = "framework13-amd-ryzen";

  imports = [
    (selfPath "hosts/framework13-amd-ryzen/hardware-configuration.nix")
    (selfPath "modules/nixos/boot.nix")
    (selfPath "modules/nixos/networking.nix")
    (selfPath "modules/nixos/locale.nix")
    (selfPath "modules/nixos/desktop-cosmic.nix")
    (selfPath "modules/nixos/audio-printing.nix")
    (selfPath "modules/nixos/containers.nix")
    (selfPath "modules/nixos/ssh.nix")
    (selfPath "modules/nixos/security.nix")
    (selfPath "modules/nixos/user.nix")
    (selfPath "modules/nixos/hermes.nix")
    (selfPath "modules/nixos/base.nix")
    inputs.home-manager.nixosModules.home-manager
    inputs.flake.inputs.hermes-agent.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users."anders" = {
      imports = [
        inputs.zen-browser.homeModules.beta
        (selfPath "home/common")
        (selfPath "home/linux")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        (selfPath "home/linux/cosmic/panel.nix")
        (selfPath "home/linux/cosmic/theme.nix")
        (selfPath "home/linux/cosmic/wallpaper.nix")
      ];
      home.username = "anders";
      home.homeDirectory = "/home/anders";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs selfPath; };
  };

  system.stateVersion = "26.05";
}
