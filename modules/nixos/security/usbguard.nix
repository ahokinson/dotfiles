# Hardening that doesn't belong to another module. SSH is in ssh.nix.
_: {
  # Restricts who can invoke sudo at all, not just what sudoers permits.
  security.sudo.execWheelOnly = true;

  # presentDevicePolicy "allow" only covers what is connected when the daemon
  # starts. Anything plugged in later hits insertedDevicePolicy's default of
  # block, so a new Expansion Card needs `usbguard allow-device`.
  services.usbguard = {
    enable = true;
    presentDevicePolicy = "allow";
  };
}
