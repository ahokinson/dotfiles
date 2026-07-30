# Catppuccin Frappe theming for Linux. Applies to all Linux hosts (NixOS and
# Asahi Fedora), so GTK + Kvantum are enabled here even though Asahi has no
# Plasma — Kvantum merely no-ops where there are no Qt5/6 apps using it, and
# GTK covers Adwaita apps on both systems.
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

    # `gtk.icon` defaults to catppuccin.autoEnable so it is already true;
    # kvantum likewise. `cursors` opts out of auto-enable so set it here.
    cursors.enable = true;
  };

  # Qt plumbing: Plasma provides the platform theme; Kvantum provides the
  # actual style. The catppuccin kvantum module asserts that
  # `qt.style.name == "kvantum"`.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };

  # The catppuccin cursors module only sets `home.pointerCursor.{name,package}`;
  # HM now requires `enable = true` explicitly (silences a deprecation warning).
  home.pointerCursor.enable = true;
}