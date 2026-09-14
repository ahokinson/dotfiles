# Linux only: no Darwin build of pkgs.chromium exists (see
# modules/darwin/system/chromium.nix for how the Mac hosts get the binary
# instead). enableWideVine bundles nixpkgs' own licensed Widevine CDM so DRM
# playback works out of the box.
{ pkgs, lib, ... }:
{
  programs.chromium = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
    enable = true;
    package = pkgs.chromium.override { enableWideVine = true; };
  };
}
