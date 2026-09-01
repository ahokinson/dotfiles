{ lib, ... }: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Backed by a channel database this flakes-only system never populates, and
  # its command_not_found_handler would shadow the nix-index one installed by
  # home/common/nix-index.nix.
  programs.command-not-found.enable = false;
  # cores is what a single derivation gets to itself, so it's the one that
  # decides how long a big Rust workspace takes; max-jobs is how many
  # derivations run at once. Worst case is max-jobs x cores, sized here to
  # framework13's sixteen threads - the fans are held down by the CPU quota
  # below rather than by keeping these numbers small, which throttles one
  # large build to 2 of 16 threads even when nothing else is running.
  # mkDefault so a host with a different core count can rescale both; the
  # ten-core Asahi pair does, in hosts/asahi-common.nix.
  nix.settings.max-jobs = lib.mkDefault 2;
  nix.settings.cores = lib.mkDefault 8;

  # The actual thermal cap, applied to every build process the daemon forks
  # whatever parallelism it asked for. This is the number to trade build
  # speed against fan noise with, not the two above.
  #
  # 800% is eight threads' worth, half of framework13's sixteen. It is an
  # absolute figure rather than a share of the machine, so it means something
  # different on a host with a different core count - the ten-core Asahi pair
  # would be capped at 80% by this number rather than the intended half.
  # mkDefault so they set their own; hosts/asahi-common.nix does.
  systemd.services.nix-daemon.serviceConfig.CPUQuota = lib.mkDefault "800%";

  # Builds only take CPU that nothing else wants, so a rebuild doesn't
  # compete with the desktop. nixpkgs recommends this policy specifically for
  # interactively-used portables; the tradeoff is that a build running
  # against sustained foreground load can be starved.
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
