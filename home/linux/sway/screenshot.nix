# cosmic-screenshot (home/linux/cosmic/shortcuts.nix) only works inside
# cosmic-session; grim+slurp is the wlroots-ecosystem equivalent, bound to
# the same Ctrl+Shift+3/4 keys in compositor.nix. grim doesn't create its
# output directory.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.grim
    pkgs.slurp
  ];

  home.file."Pictures/Screenshots/.keep".text = "";
}
