{
  pkgs,
  lib,
  selfPath,
  osConfig ? null,
  ...
}:
let
  sharedFonts = import (selfPath "home/common/theme/fonts.nix") { inherit pkgs; };
  # macOS installs the fonts system-wide (modules/darwin/system) and ignores
  # fontconfig, so the home-level install is Linux-only.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  inherit ((import (selfPath "home/common/lib/host.nix") { inherit osConfig; })) forWork;
  catalog = import ./catalog {
    inherit
      pkgs
      lib
      isDarwin
      forWork
      sharedFonts
      ;
  };
in
{
  home.packages = catalog;

  fonts.fontconfig.enable = lib.mkIf (!isDarwin) true;
}
