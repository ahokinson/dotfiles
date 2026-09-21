{
  pkgs,
  isDarwin,
  ...
}:
with pkgs;
# baobab's darwin build has no real windowing backend behind it (nixpkgs'
# gtk4 only wires up X11 there); grandperspective is the native macOS
# equivalent instead.
if isDarwin then [ grandperspective ] else [ baobab ]
