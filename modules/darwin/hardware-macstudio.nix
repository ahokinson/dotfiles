# No declarative pmset module in nix-darwin, hence the activation script.
_: {
  system.activationScripts.postActivation.text = ''
    # Never sleep on AC. The display still sleeps on its own.
    /usr/bin/pmset -c sleep 0
  '';
}
