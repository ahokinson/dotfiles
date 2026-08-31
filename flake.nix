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

    # Own tools, each packaging itself. Tag-pinned on purpose: `nix flake
    # update` will not move these, so a bump stays a deliberate one-line edit
    # reviewed as a diff.
    bloom = {
      url = "github:ahokinson/bloom/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Also vends pkgs.tirith and pkgs.cupcake (the binaries it wraps onto its
    # own PATH), so there is exactly one pinned copy of each rather than a
    # second, independently drifting one.
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

    # Was reached through the old `flake` input. No `follows`: hermes-agent
    # pins its own nixpkgs deliberately. Tag-pinned for the same reason as the
    # tools above: its default branch is shared development, so an unpinned URL
    # left `nix flake update` landing on whatever commit was on top that day.
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

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pharos = {
      url = "github:ahokinson/pharos/v0.2.3";
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

    # Also a plain source tree. Only its icons/ directory is used: monochrome
    # single-path brand glyphs (CC0), recolored onto Frappe tiles by
    # home/common/icons.nix.
    simple-icons.url = "github:simple-icons/simple-icons";
    simple-icons.flake = false;

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Taken as an input rather than just a package so we can use its
    # home-manager module for proper macOS .app bundle installation.
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
      # Joins a repo-root-relative subpath onto the flake's own source, e.g.
      # `selfPath "hosts/foo"`. Avoids `../../`-style relative imports, which
      # get fragile as directories nest deeper.
      selfPath = subpath: self + "/${subpath}";

      # Single source of truth for the account every host provisions and
      # every home-manager profile targets, threaded through specialArgs the
      # same way selfPath is.
      username = "anders";

      overlays.default = import (selfPath "overlays/default.nix") inputs;

      # Every nixosConfigurations/darwinConfigurations entry below is the
      # same 3-line shape - hostPlatform, the shared overlay, one host
      # import - differing only in which platform and which hosts/<dir>.
      # Factored here so each host declaration is just its platform + path.
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

      # Each host pins its own platform, so this list exists purely for the
      # per-system outputs at the bottom (formatter, checks, devShells).
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs (selfPath "treefmt.nix"));

      # `nix develop` (or direnv, via .envrc) installs these as git hooks;
      # `nix flake check` runs them in a sandbox. ripsecrets rather than the
      # trufflehog hook because trufflehog's --only-verified pass reaches out
      # over the network to validate candidates, which the sandbox forbids.
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
      # --- NixOS (current box, x86_64-linux) ---
      # Framework Laptop 13, AMD Ryzen AI 7 350. Hostname:
      # `framework13-amd-ryzen`.
      nixosConfigurations.framework13-amd-ryzen = mkNixos "x86_64-linux" "framework13-amd-ryzen";

      # --- macOS (Apple Silicon, aarch64-darwin) ---
      # MacBook Pro 14", M1 Pro. Hardware tweaks: modules/darwin/hardware-macbookpro14.nix
      darwinConfigurations.macbookpro14-m1-pro = mkDarwin "macbookpro14-m1-pro";

      # Mac Studio, M1 Max. Hardware tweaks: modules/darwin/hardware-macstudio.nix
      darwinConfigurations.macstudio-m1-max = mkDarwin "macstudio-m1-max";

      # MacBook Pro 16", M5. Hardware tweaks: modules/darwin/hardware-macbookpro16.nix
      # (macOS-only, does not dual-boot Asahi.)
      darwinConfigurations.macbookpro16-m5 = mkDarwin "macbookpro16-m5";

      # --- Asahi NixOS (aarch64-linux, bare metal on Apple Silicon) ---
      # Named per-machine, short forms of each machine's darwin hostname (the
      # same Macs dual-boot both). Hostnames: `bookpro14-m1-pro`,
      # `studio-m1-max`.
      nixosConfigurations.bookpro14-m1-pro = mkNixos "aarch64-linux" "bookpro14-m1-pro";

      nixosConfigurations.studio-m1-max = mkNixos "aarch64-linux" "studio-m1-max";

      # `nix fmt` - nixfmt, deadnix and statix over every .nix file. Config
      # lives in treefmt.nix.
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # `nix flake check` - what CI runs alongside evaluating every host.
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
        pre-commit = gitHooks.${pkgs.system};
      });

      # `nix develop` installs the git hooks and puts the formatters on PATH.
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
