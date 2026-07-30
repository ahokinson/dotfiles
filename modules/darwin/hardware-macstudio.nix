# Desktop-specific darwin system settings (always plugged in, no battery).
#
# Power management: nix-darwin has no declarative pmset module, so this uses
# an activation script, applied only to the AC power source.
#
# Not controllable via nix-darwin/pmset/defaults (left as manual System
# Settings toggles, or not applicable to this hardware): external-display
# arrangement is per-session state, not a declarative option.
{ ... }: {
  system.activationScripts.postActivation.text = ''
    # Always-on desktop: never let the system sleep on AC (display can still
    # sleep independently — this only affects full system sleep).
    /usr/bin/pmset -c sleep 0
  '';
}
