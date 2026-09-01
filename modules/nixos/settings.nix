{ lib, ... }: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Backed by a channel database a flakes-only system never populates, and it
  # shadows the nix-index handler from home/common/nix-index.nix.
  programs.command-not-found.enable = false;
  # Worst case is max-jobs x cores, sized to framework13's sixteen threads.
  # mkDefault so a host with a different core count rescales both; the
  # ten-core Asahi pair does, in hosts/asahi-common.nix.
  nix.settings.max-jobs = lib.mkDefault 2;
  nix.settings.cores = lib.mkDefault 8;

  # The real cap, applied to every build process the daemon forks whatever
  # parallelism it asked for. Trade build speed against fan noise here, not
  # above. 800% is eight threads, half of framework13's sixteen - an absolute
  # figure, so mkDefault and the Asahi hosts set their own.
  systemd.services.nix-daemon.serviceConfig.CPUQuota = lib.mkDefault "800%";

  # Builds only take CPU nothing else wants, so they never compete with the
  # desktop. A build under sustained foreground load can be starved.
  nix.daemonCPUSchedPolicy = "idle";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;
  # mitmproxy -> python ecdsa has CVE-2024-23342 present in legacy curve support.
  nixpkgs.config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];
}
