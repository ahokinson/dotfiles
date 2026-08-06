# System-wide hardening that doesn't belong to a single other concern (see
# also modules/nixos/ssh.nix for SSH-specific hardening).
{ ... }: {
  # Restricts who can even invoke /usr/bin/sudo to the wheel group, rather
  # than relying solely on sudoers rules to gate privilege escalation.
  security.sudo.execWheelOnly = true;

  # USB device allowlisting - mitigates BadUSB/evil-maid attacks on a laptop
  # that leaves your side. presentDevicePolicy is set to "allow" so whatever
  # is already connected when the daemon first starts (built-in keyboard/
  # trackpad, whatever's in the Expansion Card slots at boot) isn't locked
  # out. Anything plugged in *after* that falls through to
  # insertedDevicePolicy's default (apply-policy -> implicitPolicyTarget's
  # default of block) - so a new Expansion Card needs an explicit
  # `usbguard allow-device` before it'll work.
  services.usbguard = {
    enable = true;
    presentDevicePolicy = "allow";
  };
}
