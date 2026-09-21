# pkgs.slack has no aarch64-linux build; the Asahi hosts get slacky, an
# unofficial ARM64 Linux client.
{ pkgs, hostFacts, ... }:
let
  inherit (hostFacts) isApple;
in
{
  home.packages = [
    # ghostty installed via programs.ghostty (home/common/terminal/ghostty) instead.
    (if isApple then pkgs.slacky else pkgs.slack)
  ];
}
