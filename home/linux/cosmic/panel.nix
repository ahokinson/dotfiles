# COSMIC's default top-panel + dock split replaces plasma-panel.nix's
# hand-built bottom dock, so this file only overrides what differs from
# stock COSMIC: the pinned-app favorites list, mirroring the macOS Dock
# (modules/darwin/system.nix: dock.persistent-apps) and the old Plasma
# panel (home/linux/plasma-panel.nix: iconTasks.launchers).
#
# Deliberately does NOT touch wayland.desktopManager.cosmic.panels: setting
# it at all replaces COSMIC's *entire* panel registry (verified against
# cosmic-manager's modules/panels.nix — it writes com.system76.CosmicPanel's
# `entries.entries` as the literal list of panel names given), so a partial
# override there would silently drop the stock top panel rather than just
# tweak the dock. The app-list applet's `favorites` option is independent
# of the panel registry and safe to set alone.
#
# Favorite ids are each app's .desktop filename with the extension
# stripped (confirmed against cosmic-manager's app-list applet module: its
# own example uses "firefox" for firefox.desktop and
# "com.system76.CosmicFiles" for com.system76.CosmicFiles.desktop).
{ ... }: {
  # cosmic-manager's own master switch (home-manager level) - distinct from
  # services.desktopManager.cosmic.enable (NixOS level, modules/nixos/
  # desktop-cosmic.nix), which only turns on the system session and doesn't
  # imply this. The app-list applet module asserts on it directly.
  wayland.desktopManager.cosmic.enable = true;

  wayland.desktopManager.cosmic.applets."app-list".settings.favorites = [
    "zen-beta"
    "com.mitchellh.ghostty"
  ];
}
