# Shared by every Asahi NixOS host (bookpro14-m1-pro, studio-m1-max): the
# modular system config, home-manager wiring, and Apple-Silicon-specific
# overrides that are otherwise byte-for-byte identical between them. Each
# host's own default.nix supplies just its hostname and hardware-config
# import.
{
  inputs,
  selfPath,
  username,
  ...
}:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    (selfPath "modules/nixos/audio.nix")
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

  hardware.asahi.enable = true;

  # Broadcom Wi-Fi on Apple Silicon needs iwd, per nixos-apple-silicon's docs
  # (NetworkManager's default wpa_supplicant backend isn't supported here).
  networking.networkmanager.wifi.backend = "iwd";

  # Not modules/nixos/boot.nix: that module assumes framework13's AMD/EFI
  # setup (canTouchEfiVariables = true, a Plymouth theme never verified on
  # this hardware). nixos-apple-silicon's own install guide calls for
  # canTouchEfiVariables = false instead.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

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
