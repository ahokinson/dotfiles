{ pkgs, selfPath, ... }:
let
  sharedFonts = import (selfPath "home/common/theme/fonts.nix") { inherit pkgs; };
in
{
  fonts.packages = sharedFonts.packages;
}
