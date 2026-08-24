{
  description = "Unified Nix flake for NixOS (incl. Asahi/Apple Silicon) and macOS.";

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

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
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

      # --- Asahi NixOS (aarch64-linux, bare metal on Apple Silicon) ---
      # Named per-machine, short forms of each machine's darwin hostname (the
      # same Macs dual-boot both). Hostnames: `bookpro14-m1-pro`,
      # `studio-m1-max` — see hosts/<name>/default.nix.
      nixosConfigurations.bookpro14-m1-pro = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-linux"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/bookpro14-m1-pro")
        ];
      };

      nixosConfigurations.studio-m1-max = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs selfPath; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-linux"; }
          { nixpkgs.overlays = [ overlays.default ]; }
          (selfPath "hosts/studio-m1-max")
        ];
      };

      # Expose for downstream compositors/hosts if needed.
      inherit overlays;
    };
}