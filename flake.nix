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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Own tools, each packaging itself. Tag-pinned so `nix flake update`
    # cannot move them and a bump stays a reviewable one-line edit.
    bloom = {
      url = "github:ahokinson/bloom/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Also vends pkgs.tirith and pkgs.cupcake, the binaries it wraps onto its
    # own PATH, so there is one pinned copy of each.
    cerberus = {
      url = "github:ahokinson/cerberus/v0.1.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipleaks = {
      url = "github:ahokinson/clipleaks/v0.1.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `follows`: hermes-agent pins its own nixpkgs deliberately.
    # Tag-pinned because its default branch is shared development.
    hermes-agent.url = "github:NousResearch/hermes-agent/v2026.8.27";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `follows`: like hermes-agent above, nixos-raspberrypi pins its own
    # nixpkgs deliberately - its Pi-specific kernel/firmware/u-boot
    # packaging is validated against that release branch, and forcing it
    # onto this repo's nixos-unstable on every `nix flake update` would
    # risk breaking ARM kernel/DTB builds for the sake of two hosts with no
    # other reason to track unstable.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pharos = {
      url = "github:ahokinson/pharos/v0.2.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    psyche = {
      url = "github:ahokinson/psyche/v0.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    reliquary = {
      url = "github:ahokinson/reliquary/v0.1.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plain source tree, not a flake.
    nvim.url = "github:ahokinson/nvim";
    nvim.flake = false;

    # Also a plain source tree. Only icons/ is used, recolored onto Mocha
    # tiles by home/common/icons.nix.
    simple-icons.url = "github:simple-icons/simple-icons";
    simple-icons.flake = false;

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # An input, not just a package: its home-manager module is what installs
    # a proper macOS .app bundle.
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      # Joins a repo-root-relative subpath onto the flake's own source, so
      # nothing needs `../../`-style relative imports.
      selfPath = subpath: self + "/${subpath}";

      # The account every host provisions and every home-manager profile
      # targets, threaded through specialArgs like selfPath.
      username = "anders";

      overlays.default = import (selfPath "overlays/default.nix") inputs;

      # Every host entry below is the same three lines - hostPlatform, the
      # shared overlay, one host import - so only the platform and the path
      # differ. Factored here to keep each declaration to those two.
      mkNixos =
        hostPlatform: hostDir:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs selfPath username; };
          modules = [
            { nixpkgs.hostPlatform = hostPlatform; }
            { nixpkgs.overlays = [ overlays.default ]; }
            (selfPath "hosts/${hostDir}")
          ];
        };

      mkDarwin =
        hostDir:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs selfPath username; };
          modules = [
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            { nixpkgs.overlays = [ overlays.default ]; }
            (selfPath "hosts/${hostDir}")
          ];
        };

      # Raspberry Pi hosts use nixos-raspberrypi's own nixosSystem instead of
      # nixpkgs.lib.nixosSystem: it wires in Pi-specific kernel/firmware
      # packaging and disko-integrated boot provisioning nixos-anywhere needs
      # for a fully non-interactive install. Board support and the disko
      # module live in hosts/raspberrypi-common.nix, so this stays as short
      # as mkNixos. No overlays.default: nothing these two hosts reuse needs
      # it, and it would cross nixos-raspberrypi's own (older, deliberately
      # unfollowed) nixpkgs revision for no reason.
      mkRaspberryPi =
        hostDir:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs selfPath username; };
          modules = [ (selfPath "hosts/${hostDir}") ];
        };

      # Each host pins its own platform; this list is only for the per-system
      # outputs at the bottom.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs (selfPath "treefmt.nix"));

      # `nix develop`, or direnv via .envrc, installs these as git hooks;
      # `nix flake check` runs them sandboxed. ripsecrets rather than the
      # trufflehog hook, whose --only-verified pass needs network the sandbox
      # forbids.
      gitHooks = eachSystem (
        pkgs:
        inputs.git-hooks.lib.${pkgs.system}.run {
          src = self;
          hooks = {
            treefmt.enable = true;
            treefmt.packageOverrides.treefmt = treefmtEval.${pkgs.system}.config.build.wrapper;
            ripsecrets.enable = true;
          };
        }
      );
    in
    {
      # --- NixOS (x86_64-linux) ---
      nixosConfigurations.framework13-amd-ryzen = mkNixos "x86_64-linux" "framework13-amd-ryzen";

      # --- macOS (aarch64-darwin) ---
      darwinConfigurations.macbookpro14-m1-pro = mkDarwin "macbookpro14-m1-pro";

      darwinConfigurations.macstudio-m1-max = mkDarwin "macstudio-m1-max";

      # The only Mac that does not dual-boot Asahi.
      darwinConfigurations.macbookpro16-m5 = mkDarwin "macbookpro16-m5";

      # --- Asahi NixOS (aarch64-linux, bare metal on Apple Silicon) ---
      # Short forms of the same machines' darwin hostnames above.
      nixosConfigurations.bookpro14-m1-pro = mkNixos "aarch64-linux" "bookpro14-m1-pro";

      nixosConfigurations.studio-m1-max = mkNixos "aarch64-linux" "studio-m1-max";

      # --- Raspberry Pi 4 (aarch64-linux, headless appliances) ---
      nixosConfigurations.pi-hole = mkRaspberryPi "pi-hole";

      nixosConfigurations.pi-nas = mkRaspberryPi "pi-nas";

      # nixfmt, deadnix and statix over every .nix file; see treefmt.nix.
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # What CI runs alongside evaluating every host.
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
        pre-commit = gitHooks.${pkgs.system};
      });

      # Installs the git hooks and puts the formatters on PATH.
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          inherit (gitHooks.${pkgs.system}) shellHook;
          packages = gitHooks.${pkgs.system}.enabledPackages;
        };
      });

      # Expose for downstream compositors/hosts if needed.
      inherit overlays;
    };
}
