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
    # `cursors` opts out of auto-enable and is deliberately left disabled -
    # the Catppuccin cursor theme isn't good, so cursors stay on whatever
    # theme the desktop environment defaults to. `kvantum` is left to
    # catppuccin-qt.nix on hosts that import it.

    # delta and bat are themed in home/common (git/default.nix, bat/default.nix);
    # disable the module's ports here so they aren't double-themed on Linux.
    delta.enable = false;
    bat.enable = false;
  };
}