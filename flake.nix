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
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      overlays.default = import ./overlays/default.nix inputs;

      mkPkgs = system: import nixpkgs {
        inherit system;
        overlays = [ overlays.default ];
        config.allowUnfree = true;
      };

      in
    {
      # --- NixOS (current box, x86_64-linux) ---
      # Framework Laptop 13, AMD Ryzen AI 7 350. Hostname:
      # `framework13-amd-ryzen` — see hosts/framework13-amd-ryzen/default.nix.
      nixosConfigurations.framework13-amd-ryzen = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          ./hosts/framework13-amd-ryzen
        ];
      };

      # --- macOS (Apple Silicon, aarch64-darwin) ---
      # MacBook Pro 14", M1 Pro. Hardware tweaks: modules/darwin/hardware-macbookpro14.nix
      darwinConfigurations.macbookpro14-m1-pro = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          ./hosts/macbookpro14-m1-pro
        ];
      };

      # Mac Studio, M1 Max. Hardware tweaks: modules/darwin/hardware-macstudio.nix
      darwinConfigurations.macstudio-m1-max = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          ./hosts/macstudio-m1-max
        ];
      };

      # MacBook Pro 16", M5. Hardware tweaks: modules/darwin/hardware-macbookpro16.nix
      # (macOS-only — does not dual-boot Asahi.)
      darwinConfigurations.macbookpro16-m5 = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          ./hosts/macbookpro16-m5
        ];
      };

      # --- Asahi Fedora (aarch64-linux) — standalone home-manager profile.
      # Both macs dual-boot Asahi and share a single home-manager profile:
      # home-manager owns only $HOME, so it cannot distinguish machines.
      # Set each machine's *system* hostname via `hostnamectl set-hostname <name>`
      # separately; this entry is identical on both.
      homeConfigurations."anders@asahi" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "aarch64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [
          {
            home.username = "anders";
            home.homeDirectory = "/home/anders";
            home.stateVersion = "26.05";
            home.backupFileExtension = "hm-backup";
          }
          ./home/common
          ./home/linux
        ];
      };

      # Expose for downstream compositors/hosts if needed.
      inherit overlays;
    };
}