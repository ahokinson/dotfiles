{
  description = "Unified Nix flake for NixOS, macOS (Apple Silicon), and Asahi Fedora.";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    flake.url = "github:ahokinson/flake";
    flake.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Own input (not reached through ahokinson/flake) so we can use its
    # home-manager module for proper macOS .app bundle installation.
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Joins a repo-root-relative subpath onto the flake's own source,
      # e.g. `selfPath "hosts/foo"` — avoids `../../`-style relative imports
      # that get fragile with directory nesting.
      selfPath = subpath: self + "/${subpath}";

      overlays.default = import (selfPath "overlays/default.nix") inputs;

      mkPkgs = system: import nixpkgs {
        inherit system;
        overlays = [ overlays.default ];
        config.allowUnfree = true;
      };

      # Both macs that dual-boot Asahi share one home-manager config
      # (home-manager owns only $HOME, so there's nothing host-specific to
      # configure) — exposed under two output names below, one per machine.
      # home.backupFileExtension is a nix-darwin/NixOS module-integration
      # option; it doesn't exist for a standalone homeManagerConfiguration
      # like this one. The standalone equivalent is the `-b <ext>` CLI flag
      # (see switch.zsh's home:switch/build/dry commands).
      asahiHome = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "aarch64-linux";
        extraSpecialArgs = { inherit inputs selfPath; };
        modules = [
          {
            home.username = "anders";
            home.homeDirectory = "/home/anders";
            home.stateVersion = "26.05";
          }
          (selfPath "home/common")
          (selfPath "home/linux")
        ];
      };

      in
    {
      # --- NixOS (current box, x86_64-linux) ---
      # Framework Laptop 13, AMD Ryzen AI 7 350. Hostname:
      # `framework13-amd-ryzen` — see hosts/framework13-amd-ryzen/default.nix.
      nixosConfigurations.framework13-amd-ryzen = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/framework13-amd-ryzen")
        ];
      };

      # --- macOS (Apple Silicon, aarch64-darwin) ---
      # MacBook Pro 14", M1 Pro. Hardware tweaks: modules/darwin/hardware-macbookpro14.nix
      darwinConfigurations.macbookpro14-m1-pro = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/macbookpro14-m1-pro")
        ];
      };

      # Mac Studio, M1 Max. Hardware tweaks: modules/darwin/hardware-macstudio.nix
      darwinConfigurations.macstudio-m1-max = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/macstudio-m1-max")
        ];
      };

      # MacBook Pro 16", M5. Hardware tweaks: modules/darwin/hardware-macbookpro16.nix
      # (macOS-only — does not dual-boot Asahi.)
      darwinConfigurations.macbookpro16-m5 = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/macbookpro16-m5")
        ];
      };

      # --- Asahi Fedora (aarch64-linux) — standalone home-manager profile.
      # Named per-machine, short forms of each machine's darwin hostname
      # (never "asahi" itself, and no "user@" prefix - unlike the darwin/
      # nixos outputs above these are never confusable with each other, so
      # the extra prefix is just noise). switch.zsh picks the right one by
      # mapping the Apple Silicon device-tree codename to a hostname (see
      # ASAHI_HW_MAP) and also sets the system hostname via hostnamectl,
      # since home-manager can't do that itself.
      homeConfigurations."bookpro14-m1-pro" = asahiHome;
      homeConfigurations."studio-m1-max" = asahiHome;

      # Expose for downstream compositors/hosts if needed.
      inherit overlays;
    };
}