{
  description = "Unified Nix flake for NixOS (incl. Asahi/Apple Silicon) and macOS.";

  # Every input below fetches over plain git (git+https, shallow=1) rather
  # than the github: shorthand. github: resolves through GitHub's REST API,
  # which caps unauthenticated callers at 60 req/hour per IP - shared with
  # gh and anything else on the box hitting github.com. git+https uses the
  # ordinary smart-HTTP git protocol instead, so it isn't subject to that
  # limit at all.
  inputs = {
    catppuccin.url = "git+https://github.com/catppuccin/nix.git?shallow=1";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager = {
      url = "git+https://github.com/HeitorAugustoLN/cosmic-manager.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    disko = {
      url = "git+https://github.com/nix-community/disko.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Own tools, each packaging itself. Tag-pinned so `nix flake update`
    # cannot move them and a bump stays a reviewable one-line edit.
    bloom = {
      url = "git+https://github.com/ahokinson/bloom.git?ref=refs/tags/v0.2.1&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    busy-nas = {
      url = "git+https://github.com/ahokinson/busy-nas.git?ref=refs/tags/v0.1.3&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Also vends pkgs.tirith and pkgs.cupcake, the binaries it wraps onto its
    # own PATH, so there is one pinned copy of each.
    cerberus = {
      url = "git+https://github.com/ahokinson/cerberus.git?ref=refs/tags/v0.1.3&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipleaks = {
      url = "git+https://github.com/ahokinson/clipleaks.git?ref=refs/tags/v0.1.2&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "git+https://github.com/cachix/git-hooks.nix.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `follows`: hermes-agent pins its own nixpkgs deliberately.
    # Tag-pinned because its default branch is shared development.
    hermes-agent.url = "git+https://github.com/NousResearch/hermes-agent.git?ref=refs/tags/v2026.8.27&shallow=1";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "git+https://github.com/nix-darwin/nix-darwin.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "git+https://github.com/nix-community/nix-index-database.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "git+https://github.com/NixOS/nixos-hardware.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "git+https://github.com/nix-community/nixos-apple-silicon.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `follows`: like hermes-agent above, nixos-raspberrypi pins its own
    # nixpkgs deliberately - its Pi-specific kernel/firmware/u-boot
    # packaging is validated against that release branch, and forcing it
    # onto this repo's nixos-unstable on every `nix flake update` would
    # risk breaking ARM kernel/DTB builds for the sake of two hosts with no
    # other reason to track unstable.
    nixos-raspberrypi.url = "git+https://github.com/nvmd/nixos-raspberrypi.git?shallow=1";

    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";

    pharos = {
      url = "git+https://github.com/ahokinson/pharos.git?ref=refs/tags/v0.2.5&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    psyche = {
      url = "git+https://github.com/ahokinson/psyche.git?ref=refs/tags/v0.1.1&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    reliquary = {
      url = "git+https://github.com/ahokinson/reliquary.git?ref=refs/tags/v0.1.4&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plain source tree, not a flake.
    nvim.url = "git+https://github.com/ahokinson/nvim.git?shallow=1";
    nvim.flake = false;

    # Also a plain source tree. Only icons/ is used, recolored onto Mocha
    # tiles by home/common/icons.nix.
    simple-icons.url = "git+https://github.com/simple-icons/simple-icons.git?shallow=1";
    simple-icons.flake = false;

    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # An input, not just a package: its home-manager module is what installs
    # a proper macOS .app bundle.
    zen-browser.url = "git+https://github.com/0xc000022070/zen-browser-flake.git?shallow=1";
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
