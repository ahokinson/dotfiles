# Layered on COSMIC's defaults (data/keybindings.ron in cosmic-comp).
#
# ghostty, signal and vesktop all run with no title bar or window controls,
# so these keybinds are the only way to close, maximize, move or minimize
# them. COSMIC already binds Close (Super+Q, Alt+F4), Maximize (Super+M) and
# move (Super+drag anywhere); only Minimize has no default, added here.
{ selfPath, ... }:
let
  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronEnum;
in
{
  wayland.desktopManager.cosmic.shortcuts = [
    {
      key = "Super+N";
      action = ronEnum "Minimize";
    }
  ];
}
