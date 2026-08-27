{ lib, ... }: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Backed by a channel database this flakes-only system never populates, and
  # its command_not_found_handler would shadow the nix-index one installed by
  # home/common/nix-index.nix.
  programs.command-not-found.enable = false;
  # Cap build parallelism so the fans don't spin up.
  nix.settings.max-jobs = lib.mkDefault 2;
  nix.settings.cores = lib.mkDefault 2;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;
  # mitmproxy -> python ecdsa has CVE-2024-23342 present in legacy curve support.
  nixpkgs.config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];
}
