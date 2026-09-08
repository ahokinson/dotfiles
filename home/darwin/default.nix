{ selfPath, ... }: {
  imports = [
    (selfPath "home/darwin/monitorcontrol.nix")
    (selfPath "home/darwin/podman.nix")
    (selfPath "home/darwin/reliquary-codesign.nix")
    (selfPath "home/darwin/thaw.nix")
    (selfPath "home/darwin/wallpaper.nix")
    (selfPath "home/darwin/zen-browser.nix")
  ];

  # modules/darwin/system points screencapture.location here; without the
  # directory, screenshots silently fail to save.
  home.file."Pictures/Screenshots/.keep".text = "";
}
