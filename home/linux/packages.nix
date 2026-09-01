{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ghostty installed via programs.ghostty (home/common/ghostty) instead.
  ];
}
