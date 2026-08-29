# Custom keybinds layered on top of COSMIC's own defaults (data/keybindings.ron
# in cosmic-comp's source), shared by every COSMIC host.
#
# Close (Super+Q, Alt+F4), Maximize (Super+M), and moving a window
# (Super+drag anywhere on it, independent of any title bar) are already
# bound by default - only Minimize has no default, added here. This matters
# now that ghostty/signal/vesktop (home/common/ghostty/settings.nix,
# overlays/signal.nix, home/common/vesktop.nix) all run without a title bar
# or window controls, relying on these keybinds for everything a traffic
# light used to do.
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
