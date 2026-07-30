# Laptop-specific darwin system settings.
#
# Power management: nix-darwin has no declarative pmset module, so this uses
# an activation script. Only touches battery-power behavior; AC and shared
# settings stay at their macOS defaults.
#
# Not controllable via nix-darwin/pmset/defaults (left as manual System
# Settings toggles): keyboard backlight timeout, ProMotion refresh rate,
# battery charge thresholds, lid/clamshell behavior. macOS doesn't expose
# these declaratively.
{ ... }: {
  system.activationScripts.postActivation.text = ''
    # Disable wake-on-network-access while on battery to save power; leave
    # it enabled on AC (pmset's own default).
    /usr/bin/pmset -b womp 0
  '';
}
