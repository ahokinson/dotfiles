{
  description = "Unified Nix flake for NixOS, macOS (Apple Silicon), and Asahi Fedora.";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Plain source tree, not a flake - see home/common/cupcake/default.nix.
    cupcake.url = "github:ahokinson/cupcake";
    cupcake.flake = false;

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

    # Plain source tree, not a flake - see home/common/nvim/default.nix.
    nvim.url = "github:ahokinson/nvim";
    nvim.flake = false;

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
      # A standalone homeManagerConfiguration has no home.backupFileExtension
      # option; the equivalent is the `-b <ext>` CLI flag (see README.md).
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
          (selfPath "home/linux/cosmic")
          inputs.cosmic-manager.homeManagerModules.cosmic-manager
          inputs.zen-browser.homeModules.beta
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
      # (see README.md for the apply command, including the standalone
      # home-manager flags this needs that nixos-rebuild/darwin-rebuild
      # don't).
      # Apply with: NIX_CONFIG="experimental-features = nix-command flakes"
      #   nix run github:nix-community/home-manager -- switch -b hm-backup
      #   --flake ~/.dotfiles#bookpro14-m1-pro
      homeConfigurations."bookpro14-m1-pro" = asahiHome;
      # Apply with: same as above, #studio-m1-max
      homeConfigurations."studio-m1-max" = asahiHome;

      # Expose for downstream compositors/hosts if needed.
      inherit overlays;
    };
}