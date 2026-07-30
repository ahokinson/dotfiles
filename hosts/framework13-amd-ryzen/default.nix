# Top-level NixOS host configuration — assembles the modular system config
# and wires home-manager (common profile) for user `anders`.
# Hostname reflects the underlying hardware: Framework Laptop 13 with AMD
# Ryzen AI 7 350 (Ryzen AI 300 / "Strix Point" generation, A7 board version).
# Apply with: nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen
{ inputs, pkgs, lib, ... }:
{
  networking.hostName = "framework13-amd-ryzen";

  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/audio-printing.nix
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/hermes.nix
    ../../modules/nixos/base.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.flake.inputs.hermes-agent.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users."anders" = {
      imports = [
        ../../home/common
        ../../home/linux
      ];
      home.username = "anders";
      home.homeDirectory = "/home/anders";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = "26.05";
}