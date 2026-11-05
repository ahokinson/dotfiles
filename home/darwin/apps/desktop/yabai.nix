# Hotkeys for modules/darwin/services/yabai.nix's manual/float-first tiling.
# Appends to the shared skhdrc that home/darwin/apps/desktop/lifesaver.nix
# owns (xdg.configFile.*.text is `types.lines` and merges across modules) —
# only one skhd process should ever run, so this doesn't declare its own.
#
# skhd's launchd agent (lifesaver.nix) doesn't set PATH, so every command
# below is fully-qualified rather than relying on it, matching how that
# module already invokes lifesaver itself.
#
# No alt on the split keyboard this runs from, so everything lives under
# ctrl+cmd (+shift for the second tier) instead of the usual alt scheme.
# ctrl+cmd-f and ctrl+cmd-space are avoided: macOS reserves those globally
# for Enter Full Screen and the emoji picker. Native tiling's own default
# (fn+ctrl+arrows) doesn't overlap this either.
# window --space is deliberately left unbound (see yabai.nix's own header).
{ pkgs, ... }:
let
  yb = "${pkgs.yabai}/bin/yabai";
  jq = "${pkgs.jq}/bin/jq";
in
{
  xdg.configFile."skhd/skhdrc".text = ''
    ctrl + cmd - h : ${yb} -m window --focus west
    ctrl + cmd - j : ${yb} -m window --focus south
    ctrl + cmd - k : ${yb} -m window --focus north
    ctrl + cmd - l : ${yb} -m window --focus east

    ctrl + cmd + shift - h : ${yb} -m window --swap west
    ctrl + cmd + shift - j : ${yb} -m window --swap south
    ctrl + cmd + shift - k : ${yb} -m window --swap north
    ctrl + cmd + shift - l : ${yb} -m window --swap east

    ctrl + cmd - left : ${yb} -m window --grid 1:2:0:0:1:1
    ctrl + cmd - right : ${yb} -m window --grid 1:2:1:0:1:1
    ctrl + cmd - up : ${yb} -m window --grid 2:1:0:0:1:1
    ctrl + cmd - down : ${yb} -m window --grid 2:1:0:1:1:1
    ctrl + cmd - return : ${yb} -m window --grid 1:1:0:0:1:1

    ctrl + cmd + shift - left : ${yb} -m window --resize left:-40:0
    ctrl + cmd + shift - right : ${yb} -m window --resize right:40:0
    ctrl + cmd + shift - up : ${yb} -m window --resize top:0:-40
    ctrl + cmd + shift - down : ${yb} -m window --resize bottom:0:40

    ctrl + cmd - y : ${yb} -m window --toggle float

    # space --layout bsp only governs new windows going forward; it doesn't
    # retroactively un-float windows that opened while the space was float
    # (yabai issues #230/#586/#1746). So also walk every currently-floating
    # window on this space and toggle it managed, or the "split" is a no-op.
    ctrl + cmd - b : ${yb} -m space --layout bsp; ${yb} -m query --windows --space | ${jq} -r '.[] | select(."is-floating") | .id' | while read -r id; do ${yb} -m window "$id" --toggle float; done
    ctrl + cmd + shift - b : ${yb} -m space --layout float

    ctrl + cmd - 0 : ${yb} -m space --balance
  '';
}
