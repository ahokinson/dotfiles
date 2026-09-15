# No declarative pmset module in nix-darwin, hence the activation script -
# same gap laptop-wake.nix works around.
_: {
  system.activationScripts.postActivation.text = ''
    # LifeSaver is the deliberate fullscreen idle display. No automatic
    # display, disk, or system sleep may interrupt it, on AC or battery.
    /usr/bin/pmset -a displaysleep 0
    /usr/bin/pmset -a sleep 0
    /usr/bin/pmset -a disksleep 0
  '';
}
