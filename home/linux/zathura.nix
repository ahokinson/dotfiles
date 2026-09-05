# programs.zathura rather than a bare package so home-manager writes
# zathurarc, which is also where the catppuccin target (autoEnable,
# home/linux/catppuccin.nix) drops its Mocha include. Vim-style keys
# (hjkl scroll, / search, : command mode) are zathura's defaults, so
# there are no mappings to override.
{ pkgs, ... }:
{
  programs.zathura = {
    enable = true;
    # pkgs.zathura defaults to the mupdf backend; poppler instead, per
    # zathura's own recommendation, via the wrapper's useMupdf toggle.
    package = pkgs.zathuraPkgs.zathuraWrapper.override { useMupdf = false; };
  };
}
