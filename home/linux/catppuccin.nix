# Catppuccin Frappe theming for Linux. Applies to all Linux hosts (NixOS and
# Asahi Fedora) - GTK/icons/cursors only. Qt/Kvantum theming is NixOS-only,
# see catppuccin-qt.nix: it installs Nix-built Qt platform-theme/Kvantum
# plugins and points Qt apps at them via env vars, which is only safe when
# the whole Plasma/Qt stack is also Nix-built (NixOS). On Asahi, Plasma is
# Fedora's own RPM-installed build using Fedora's system Qt - pointing it at
# Nix-built plugins is an ABI mismatch that crashes every Qt/Plasma process
# on load (confirmed: this exact config caused a DrKonqi crash-loop and
# login failure on real Asahi hardware).
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    # Explicitly mirror `enable` into `autoEnable` to silence the
    # migration warning the catppuccin/nix module emits when only
    # `catppuccin.enable` is set (see modules/global.nix).
    autoEnable = true;
    flavor = "frappe";
    accent = "mauve";

    # `gtk.icon` defaults to catppuccin.autoEnable so it is already true.
    # `cursors` opts out of auto-enable so set it here. `kvantum` is left
    # to catppuccin-qt.nix on hosts that import it.
    cursors.enable = true;
  };

  # The catppuccin cursors module only sets `home.pointerCursor.{name,package}`;
  # HM now requires `enable = true` explicitly (silences a deprecation warning).
  home.pointerCursor.enable = true;
}