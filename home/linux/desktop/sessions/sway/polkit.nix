# COSMIC's own polkit prompt UI only runs inside cosmic-session
# (services.polkit is already on system-wide via modules/nixos/desktop/cosmic.nix's module
# chain, but that's the daemon, not a prompt UI). polkit_gnome draws one for
# this session - the standard choice for a plain wlroots compositor outside
# COSMIC/GNOME/KDE's own agents.
{ pkgs, ... }:
{
  wayland.windowManager.sway.extraConfig = ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
  '';
}
