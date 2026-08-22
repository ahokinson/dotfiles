# Add to system/home-manager only on macOS hosts.
{ selfPath, ... }: {
  imports = [
    (selfPath "home/darwin/monitorcontrol.nix")
    (selfPath "home/darwin/podman.nix")
    (selfPath "home/darwin/reliquary-codesign.nix")
    (selfPath "home/darwin/thaw.nix")
    (selfPath "home/darwin/wallpaper.nix")
    (selfPath "home/darwin/zen-browser.nix")
  ];

  # modules/darwin/system points screencapture.location here; make sure
  # it exists so screenshots don't silently fail to save.
  home.file."Pictures/Screenshots/.keep".text = "";
}
