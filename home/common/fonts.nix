# The fonts and family strings, in one place. Read by home/common/packages.nix,
# modules/darwin/system and home/linux/cosmic/theme.nix.
{ pkgs }:
{
  packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  monoFamily = "MesloLGS Nerd Font Mono";
  generalFamily = "MesloLGS Nerd Font";

  # Read by both ghostty and COSMIC; change here to resize everything.
  pointSize = 10;
}
