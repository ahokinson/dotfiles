{
  pkgs,
  lib,
  isDarwin,
  sharedFonts,
  ...
}:
with pkgs;
lib.flatten [
  # baobab's darwin build has no real windowing backend behind it (nixpkgs'
  # gtk4 only wires up X11 there); grandperspective is the native macOS
  # equivalent instead.
  (lib.optionals (!isDarwin) [ baobab ])
  (lib.optionals isDarwin [ grandperspective ])
  # macOS installs fonts system-wide (modules/darwin/system) and ignores
  # fontconfig, so home-level font packages are Linux-only.
  (lib.optionals (!isDarwin) sharedFonts.packages)
]
