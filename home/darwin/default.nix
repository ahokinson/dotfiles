# Add to system/home-manager only on macOS hosts.
{ ... }: {
  imports = [
    ./zsh
    ./zen-browser.nix
    ./wallpaper.nix
  ];

  # modules/darwin/system.nix points screencapture.location here; make sure
  # it exists so screenshots don't silently fail to save.
  home.file."Pictures/Screenshots/.keep".text = "";
}