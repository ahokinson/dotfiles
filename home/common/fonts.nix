# Single source of truth for which Nerd Fonts this repo installs and the
# family strings that reference them - referenced by home/common/packages.nix
# (home.packages, all platforms), modules/darwin/system.nix (fonts.packages,
# macOS system level), and home/linux/plasma.nix (Plasma's own
# general/fixed-width font settings), so these stop being independently
# hand-maintained lists that can drift apart.
{ pkgs }:
{
  packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Matches ghostty's font-family (home/common/ghostty/default.nix).
  monoFamily = "MesloLGS Nerd Font Mono";
  generalFamily = "MesloLGS Nerd Font";
}
