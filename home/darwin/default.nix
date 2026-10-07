{
  selfPath,
  lib,
  hostFacts,
  ...
}:
{
  imports = [
    (selfPath "home/darwin/apps/browsers/chromium.nix")
    (selfPath "home/darwin/apps/browsers/zen.nix")
    (selfPath "home/darwin/apps/desktop/lifesaver.nix")
    (selfPath "home/darwin/apps/desktop/monitorcontrol.nix")
    (selfPath "home/darwin/desktop/wallpaper.nix")
    (selfPath "home/darwin/development/reliquary-codesign.nix")
    (selfPath "home/darwin/theme/catppuccin.nix")
  ]
  # Podman machine's VM boundary breaks ECR credential-helper resolution
  # (see docker.nix); the work Mac runs Docker via Colima instead.
  ++ lib.optionals hostFacts.forWork [ (selfPath "home/darwin/development/docker.nix") ]
  ++ lib.optionals (!hostFacts.forWork) [ (selfPath "home/darwin/development/podman.nix") ];

  # modules/darwin/system points screencapture.location here; without the
  # directory, screenshots silently fail to save.
  home.file."Pictures/Screenshots/.keep".text = "";
}
