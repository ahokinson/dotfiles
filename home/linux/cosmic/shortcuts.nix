# Layered on COSMIC's defaults (data/keybindings.ron in cosmic-comp).
#
# ghostty, signal and vesktop all run with no title bar or window controls,
# so these keybinds are the only way to close, maximize, move or minimize
# them. COSMIC already binds Close (Super+Q, Alt+F4), Maximize (Super+M) and
# move (Super+drag anywhere); only Minimize has no default, added here.
#
# Ctrl+Shift+3/4 mimic macOS's screenshot shortcuts (Ctrl standing in for
# Cmd, since Super+Shift+3/4 are already COSMIC defaults for "move window to
# workspace 3/4"). cosmic-screenshot has no separate rectangle-only mode:
# --interactive=false grabs the whole screen with no UI (macOS's Cmd+Shift+3),
# and the default interactive mode opens one picker popup to choose
# region/window/output (closest match to macOS's Cmd+Shift+4).
{ selfPath, ... }:
let
  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronEnum ronEnumValue;
in
{
  wayland.desktopManager.cosmic.shortcuts = [
    {
      key = "Super+N";
      action = ronEnum "Minimize";
    }
    {
      key = "Ctrl+Shift+3";
      # Spawn's RON payload is a 1-tuple of the whole command line as one
      # string, not one list element per argv token - cosmic-manager's
      # ronTupleEnumOf rejects anything but a single-element list here.
      action = ronEnumValue "Spawn" [ "cosmic-screenshot --interactive=false" ];
    }
    {
      key = "Ctrl+Shift+4";
      action = ronEnumValue "Spawn" [ "cosmic-screenshot" ];
    }
  ];
}
