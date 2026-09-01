# No declarative pmset module in nix-darwin, hence the activation script.
_: {
  system.activationScripts.postActivation.text = ''
    # Disable wake-on-network on battery.
    /usr/bin/pmset -b womp 0
  '';
}
