{ pkgs, ... }: {
  # ghostty installed via home-manager (programs.ghostty) instead.
  environment.systemPackages = with pkgs; [
    git
    opencode
  ];
}
