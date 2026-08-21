# KDE Plasma 6 desktop on NixOS (currently the framework13 host). Asahi hosts
# run Fedora's own Plasma, not this module.
#
# Login (SDDM) and lock screen (kscreenlocker) can't share a theme package, so
# both are unified on Breeze + Catppuccin Frappe Blue + the shared wallpaper:
# - SDDM uses the stock Breeze greeter, re-skinned here with our wallpaper and
#   accent, and handed the CatppuccinFrappeBlue color scheme via the sddm user's
#   kdeglobals so its colors match the session.
# - The lock screen is Breeze + the global color scheme + the same wallpaper,
#   set in home/linux/plasma.nix.
# - `catppuccin-kde` installs the Frappe Blue Plasma look-and-feel + color
#   scheme + aurorae decorations for the running session.
{ pkgs, selfPath, ... }:
let
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
  colorScheme = "${pkgs.catppuccin-kde}/share/color-schemes/CatppuccinFrappeBlue.colors";

  # Stock Breeze SDDM greeter copied out of plasma-desktop so a theme.conf.user
  # (our wallpaper + Frappe blue accent) can be added without rebuilding it.
  breezeFrappe = pkgs.runCommandLocal "sddm-breeze-frappe" { } ''
    mkdir -p "$out/share/sddm/themes"
    cp -r ${pkgs.kdePackages.plasma-desktop}/share/sddm/themes/breeze \
      "$out/share/sddm/themes/breeze-frappe"
    chmod -R u+w "$out/share/sddm/themes/breeze-frappe"
    cat > "$out/share/sddm/themes/breeze-frappe/theme.conf.user" <<THEMECONF
    [General]
    type=image
    background=${wallpaper}
    color=#8caaee
    THEMECONF
  '';
in
{
  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze-frappe";
    };
  };

  services.desktopManager.plasma6.enable = true;

  # Plasma pulls in fwupd (services.fwupd.enable defaults to true here), but
  # its upstream fwupd-refresh.service doesn't declare After=polkit.service.
  # If the refresh timer fires while a nixos-rebuild switch is restarting
  # polkit/dbus-broker, fwupdmgr loses the race ("PolicyKit daemon is not
  # available") and the unit fails.
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };

  environment.systemPackages = with pkgs; [
    breezeFrappe
    catppuccin-kde
  ];

  # The Breeze greeter runs as the sddm user and reads its color scheme from
  # ~sddm/.config/kdeglobals; point it at the Frappe Blue scheme (a valid
  # kdeglobals) so login colors match the desktop and lock screen.
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm/.config 0750 sddm sddm - -"
    "L+ /var/lib/sddm/.config/kdeglobals - - - - ${colorScheme}"
  ];

  # Align non-KDE Qt apps with Plasma's theme machinery (Kvantum handles the
  # actual style on the home-manager side via the catppuccin kvantum port).
  qt = {
    enable = true;
    platformTheme = "kde";
  };
}
