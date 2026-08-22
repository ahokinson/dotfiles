# Kvantum/Qt theming for Asahi only. home-manager's `qt` module (used on
# NixOS via catppuccin-qt.nix) is unsafe here - it installs Nix-built Qt
# plugins and points QT_PLUGIN_PATH at them, which crashes every Qt/Plasma
# process against Fedora's system-built Qt (confirmed on real hardware, see
# catppuccin-qt.nix). This writes only the theme *data* Kvantum needs
# (SVG/config text - no compiled plugins, no QT_* env vars) and sets the
# widget style through plasma-manager's config-file writer, the same
# ABI-safe mechanism home/linux/plasma/panel.nix already uses.
#
# Requires Fedora's own Kvantum engine to be dnf-installed
# (kvantum-qt5 / kvantum) - Nix can't own that on a foreign distro; see the
# packages.nix TODO for tracking Asahi's manually-installed packages.
{ pkgs, ... }:
let
  theme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "Kvantum";
    rev = "71105d224fef95dd023691303477ce3eea487457";
    hash = "sha256-gcvCVZjVbj5fRZWaM+mZTwH/g158MH36JmMuMgCBuqQ=";
  };
  themeName = "catppuccin-frappe-mauve";
in
{
  xdg.configFile."Kvantum/${themeName}".source = "${theme}/themes/${themeName}";
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=${themeName}
  '';

  programs.plasma.configFile."kdeglobals"."KDE"."widgetStyle" = "kvantum";
}
