# No declarative pmset module in nix-darwin, hence the activation script -
# same gap laptop-wake.nix works around.
_: {
  system.activationScripts.postActivation.text = ''
    # Never idle-sleep, on AC or battery. displaysleep is left alone - the
    # screen still blanks after inactivity.
    /usr/bin/pmset -a sleep 0
    /usr/bin/pmset -a disksleep 0
  '';
}
