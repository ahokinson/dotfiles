# pkgs.slack has no aarch64-linux build; the Asahi hosts get slacky, an
# unofficial ARM64 Linux client.
{
  pkgs,
  selfPath,
  osConfig ? null,
  ...
}:
let
  isApple = import (selfPath "home/common/is-apple.nix") { inherit osConfig; };
in
{
  home.packages = with pkgs; [
    # ghostty installed via programs.ghostty (home/common/ghostty) instead.
    (if isApple then slacky else slack)
    orca-slicer # gcode for the Prusa Mini+
  ];
}
