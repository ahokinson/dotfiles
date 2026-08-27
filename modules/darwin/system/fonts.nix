{ pkgs, selfPath, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
in
{
  fonts.packages = sharedFonts.packages;
}
