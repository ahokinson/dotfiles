# KDE Plasma 6 desktop on NixOS. Applies to every host that imports this
# module (currently the framework13 NixOS host). Asahi hosts also run KDE
# Plasma via Fedora's own RPM-installed build, not this module - see
# catppuccin-qt.nix for why Qt/Kvantum theming still stays NixOS-only despite
# that (confirmed ABI crash on real Asahi hardware).
#
# Theming side:
# - SDDM uses the Catppuccin "corners" theme (sugar-candy-derived), pulled
#   from nixpkgs as `catppuccin-sddm-corners`. Its bundled background is a
#   Macchiato-flavored image (theme.conf's default), not our Frappe wallpaper
#   - overridden below via a `theme.conf.user` file (SDDM's native per-theme
#   override) so the login screen matches the desktop session and macOS.
# - The `catppuccin-kde` package installs the Catppuccin Frappe Blue Plasma
#   look-and-feel + color scheme + aurorae decorations so the running
#   session picks up the same palette system-side.
# - `qt.platformTheme = "kde"` keeps non-KDE Qt apps aligned with Plasma's
#   settings; the home-manager catppuccin module handles Qt style via
#   Kvantum separately.
{ pkgs, selfPath, ... }:
let
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
  themedSddm = pkgs.catppuccin-sddm-corners.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cat > "$out/share/sddm/themes/catppuccin-sddm-corners/theme.conf.user" <<THEMECONF
      [General]
      Background="${wallpaper}"
      THEMECONF
    '';
  });
in
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

  # themedSddm replaces the stock package (not alongside it) - both install
  # to the same theme path, so installing both would collide.
  environment.systemPackages = with pkgs; [
    themedSddm
    catppuccin-kde
  ];

  # Align non-KDE Qt apps with Plasma's theme machinery (Kvantum handles the
  # actual style on the home-manager side via the catppuccin kvantum port).
  qt = {
    enable = true;
    platformTheme = "kde";
  };
}