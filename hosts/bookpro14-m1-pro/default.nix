# Top-level NixOS host configuration — assembles the modular system config
# and wires home-manager (common profile) for user `anders`.
# Hostname reflects the underlying hardware: MacBook Pro 14", M1 Pro, running
# NixOS bare metal via nixos-apple-silicon (dual-boots macOS — see
# hosts/macbookpro14-m1-pro for that side).
# Apply with: sudo nixos-rebuild switch --flake ~/.dotfiles#bookpro14-m1-pro
{ inputs, selfPath, pkgs, lib, ... }:
{
  networking.hostName = "bookpro14-m1-pro";

  imports = [
    (selfPath "hosts/bookpro14-m1-pro/hardware-configuration.nix")
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    (selfPath "modules/nixos/audio-printing.nix")
    (selfPath "modules/nixos/containers.nix")
    (selfPath "modules/nixos/desktop-cosmic.nix")
    (selfPath "modules/nixos/hermes.nix")
    (selfPath "modules/nixos/locale.nix")
    (selfPath "modules/nixos/networking.nix")
    (selfPath "modules/nixos/packages.nix")
    (selfPath "modules/nixos/security.nix")
    (selfPath "modules/nixos/settings.nix")
    (selfPath "modules/nixos/ssh.nix")
    (selfPath "modules/nixos/user.nix")
    inputs.flake.inputs.hermes-agent.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  hardware.asahi.enable = true;

  # Broadcom Wi-Fi on Apple Silicon needs iwd, per nixos-apple-silicon's docs
  # (NetworkManager's default wpa_supplicant backend isn't supported here).
  networking.networkmanager.wifi.backend = "iwd";

  # Not modules/nixos/boot.nix — that module assumes framework13's AMD/EFI
  # setup (canTouchEfiVariables = true, a Plymouth theme never verified on
  # this hardware). nixos-apple-silicon's own install guide calls for
  # canTouchEfiVariables = false instead.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users."anders" = {
      imports = [
        (selfPath "home/common")
        (selfPath "home/linux")
        (selfPath "home/linux/cosmic")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.zen-browser.homeModules.beta
      ];
      home.username = "anders";
      home.homeDirectory = "/home/anders";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs selfPath; };
  };

  system.stateVersion = "26.05";
}
