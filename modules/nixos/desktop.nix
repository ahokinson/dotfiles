# KDE Plasma 6 desktop on NixOS. Applies to every host that imports this
# module (currently the framework13 NixOS host). Asahi hosts do not import
# this file — they run GNOME via the host-level Asahi config.
#
# Theming side:
# - SDDM uses the Catppuccin "corners" theme (sugar-candy-derived), pulled
#   from nixpkgs as `catppuccin-sddm-corners`. The package installs a single
#   theme directory under share/sddm/themes/catppuccin-sddm-corners.
# - The `catppuccin-kde` package installs the Catppuccin Frappe Blue Plasma
#   look-and-feel + color scheme + aurorae decorations so the running
#   session picks up the same palette system-side.
# - `qt.platformTheme = "kde"` keeps non-KDE Qt apps aligned with Plasma's
#   settings; the home-manager catppuccin module handles Qt style via
#   Kvantum separately.
{ pkgs, ... }:
{
  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-sddm-corners";
    };
  };

  services.desktopManager.plasma6.enable = true;

  # Provide the SDDM theme + KDE color scheme / look-and-feel at the system
  # level so the login screen and a fresh session can both find them without
  # relying on per-user installs.
  environment.systemPackages = with pkgs; [
    catppuccin-sddm-corners
    catppuccin-kde
  ];

  # Align non-KDE Qt apps with Plasma's theme machinery (Kvantum handles the
  # actual style on the home-manager side via the catppuccin kvantum port).
  qt = {
    enable = true;
    platformTheme = "kde";
  };
}