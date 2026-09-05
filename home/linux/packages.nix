# pkgs.slack has no aarch64-linux build; the Asahi hosts get slacky, an
# unofficial ARM64 Linux client (home/linux/icons/default.nix uses the same
# osConfig.hardware.asahi.enable split).
{
  pkgs,
  osConfig ? null,
  ...
}:
{
  home.packages = with pkgs; [
    # ghostty installed via programs.ghostty (home/common/ghostty) instead.
    (if osConfig.hardware.asahi.enable or false then slacky else slack)
    orca-slicer # gcode for the Prusa Mini+
  ];
}
