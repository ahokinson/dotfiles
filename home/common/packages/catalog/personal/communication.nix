{
  pkgs,
  lib,
  isDarwin,
  forWork,
  ...
}:
with pkgs;
lib.flatten [
  posting
  (lib.optionals (!forWork) [ signal-desktop ])
  # Linux gets slack (or slacky on Asahi) from home/linux/packages/default.nix;
  # pkgs.slack has no aarch64-linux build.
  (lib.optionals isDarwin [ slack ])
]
