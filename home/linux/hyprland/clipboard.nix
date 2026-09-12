# Clipboard history - neither session has one today. Systemd unit shape
# matches hypridle's (WantedBy graphical-session.target only). Bound to
# SUPER+V in compositor.nix, piped through fuzzel's dmenu mode.
{
  services.cliphist.enable = true;
}
