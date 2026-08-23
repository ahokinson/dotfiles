# Single source of truth for which Nerd Fonts this repo installs and the
# family strings that reference them - referenced by home/common/packages.nix
# (home.packages, all platforms), modules/darwin/system (fonts.packages,
# macOS system level), and home/linux/cosmic/theme.nix (COSMIC's toolkit
# interface/monospace fonts, every COSMIC host), so these stop being
# independently hand-maintained lists that can drift apart.
{ pkgs }:
{
  packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Consumed by ghostty (home/common/ghostty/settings.nix) and COSMIC
  # (home/linux/cosmic/theme.nix) so the family strings live in one place.
  monoFamily = "MesloLGS Nerd Font Mono";
  generalFamily = "MesloLGS Nerd Font";

  # Single source of truth for font size. ghostty (terminal) and COSMIC (DE)
  # both read this so the two never drift; change it here to resize everything.
  pointSize = 10;
}
