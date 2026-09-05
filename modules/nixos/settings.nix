{
  config,
  lib,
  selfPath,
  ...
}:
{
  imports = [ (selfPath "modules/nix-settings.nix") ];

  options.local.nix.buildCores = lib.mkOption {
    type = lib.types.ints.positive;
    default = 8;
    example = 5;
    description = ''
      Cores nix.settings.cores hands the daemon, and half of what
      systemd.services.nix-daemon.serviceConfig.CPUQuota caps it to (a
      100%-per-core quota). Defaults to framework13-amd-ryzen's sixteen
      threads, halved.
    '';
  };

  config = {
    # Backed by a channel database a flakes-only system never populates, and it
    # shadows the nix-index handler from home/common/nix-index.nix.
    programs.command-not-found.enable = false;
    # Worst case is max-jobs x cores, sized to framework13's sixteen threads.
    nix.settings.max-jobs = lib.mkDefault 2;
    nix.settings.cores = lib.mkDefault config.local.nix.buildCores;

    # The real cap, applied to every build process the daemon forks whatever
    # parallelism it asked for. Trade build speed against fan noise here, not
    # above.
    systemd.services.nix-daemon.serviceConfig.CPUQuota =
      lib.mkDefault "${toString (config.local.nix.buildCores * 100)}%";

    # Builds only take CPU nothing else wants, so they never compete with the
    # desktop. A build under sustained foreground load can be starved.
    nix.daemonCPUSchedPolicy = "idle";
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    # mitmproxy -> python ecdsa has CVE-2024-23342 present in legacy curve support.
    nixpkgs.config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];

    # nixos-help is unused here, and its desktop entry is synthesized inline in
    # nixpkgs' documentation module, not a swappable package, so
    # home/linux/applications.nix's NoDisplay shadow can't reach it the way
    # modules/nixos/printing.nix's cups override does. This is the only lever.
    documentation.nixos.enable = false;
  };
}
