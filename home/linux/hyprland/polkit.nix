# COSMIC's own polkit prompt UI only runs inside cosmic-session
# (services.polkit is already on system-wide via desktop-cosmic.nix's module
# chain, but that's the daemon, not a prompt UI). hyprpolkitagent is the
# Hyprland-ecosystem agent that draws one for this session.
{
  services.hyprpolkitagent.enable = true;
}
