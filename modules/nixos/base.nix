{ pkgs, lib, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Cap build parallelism so the fans don't spin up.
  nix.settings.max-jobs = lib.mkDefault 2;
  nix.settings.cores = lib.mkDefault 2;
  nixpkgs.config.allowUnfree = true;
  # mitmproxy -> python ecdsa has CVE-2024-23342 present in legacy curve support.
  nixpkgs.config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];

  # System-wide packages (moved most user tools into home-manager).
  environment.systemPackages = with pkgs; [
    # ghostty installed via home-manager (programs.ghostty) instead.
    git
    opencode
  ];

  # zsh login shell (per modules/nixos/user.nix).
  programs.zsh.enable = true;
}