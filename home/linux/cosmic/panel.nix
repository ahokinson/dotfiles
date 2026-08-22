# COSMIC's default top-panel + dock split replaces plasma-panel.nix's
# hand-built bottom dock, so this file only overrides what differs from
# stock COSMIC: the pinned-app favorites list, mirroring the macOS Dock
# (modules/darwin/system.nix: dock.persistent-apps) and the old Plasma
# panel (home/linux/plasma-panel.nix: iconTasks.launchers), plus the
# dock/menu-bar behaviour tweaks below.
#
# Deliberately does NOT touch wayland.desktopManager.cosmic.panels: setting
# it at all replaces COSMIC's *entire* panel registry (verified against
# cosmic-manager's modules/panels.nix — it writes com.system76.CosmicPanel's
# `entries.entries` as the literal list of panel names given), so a partial
# override there would silently drop the stock top panel rather than just
# tweak the dock. The app-list applet's `favorites` option is independent
# of the panel registry and safe to set alone, and per-panel keys are set
# through `configFile` instead — cosmic-manager turns that into one
# `cosmic-ctl` write per key (modules/files.nix), which never rewrites the
# registry.
#
# configFile is also the only workable route for autohide: the pinned
# cosmic-manager rev still models it as the old combined
# `autohide: Option<{handle_size, transition_time, wait_time}>`, whereas the
# installed cosmic-panel 1.5.0 splits it into an `autohide` enum
# (Never | OnOverlap | Always) plus a separate `autohide_behavior` struct
# that also carries `unhide_delay`.
#
# cosmic-manager only wires its own `restartCosmicPanel` activation hook when
# `panels` is set, so nothing restarts the panel for `configFile` writes. The
# hook is reproduced below, because cosmic-panel's live config watcher re-reads
# values without rebuilding its applet layout or re-resolving applet icons —
# changes here need the process replaced, not just reloaded.
#
# Favorite ids are each app's .desktop filename with the extension
# stripped (confirmed against cosmic-manager's app-list applet module: its
# own example uses "firefox" for firefox.desktop and
# "com.system76.CosmicFiles" for com.system76.CosmicFiles.desktop).
{ selfPath, lib, pkgs, ... }:
let
  dockApps = import (selfPath "home/common/dock-apps.nix");
  stripDesktopSuffix = id: lib.removeSuffix ".desktop" id;

  ronOptional = value: { __type = "optional"; inherit value; };
  ronEnum = variant: { __type = "enum"; inherit variant; };
in
{
  # cosmic-manager's own master switch (home-manager level) - distinct from
  # services.desktopManager.cosmic.enable (NixOS level, modules/nixos/
  # desktop-cosmic.nix), which only turns on the system session and doesn't
  # imply this. The app-list applet module asserts on it directly.
  wayland.desktopManager.cosmic.enable = true;

  wayland.desktopManager.cosmic.applets."app-list".settings.favorites =
    with dockApps; [
      (stripDesktopSuffix zen.linuxDesktopId)
      (stripDesktopSuffix ghostty.linuxDesktopId)
    ];

  # Render the top panel's buttons as icons rather than the words
  # "Applications"/"Workspaces", so the leftmost one reads as a logo the way
  # macOS's Apple menu does. Keyed by panel name; the Dock's own buttons are
  # left alone.
  # macOS menu-bar clock: weekday + month + day, 24-hour time with seconds.
  wayland.desktopManager.cosmic.applets."time".settings = {
    military_time = true;
    show_seconds = true;
  };

  wayland.desktopManager.cosmic.applets."panel-button".settings.configs = {
    __type = "map";
    value = [
      {
        key = "Panel";
        value.force_presentation = ronOptional (ronEnum "Icon");
      }
    ];
  };

  wayland.desktopManager.cosmic.configFile = {
    # macOS hides its Dock on demand; COSMIC ships autohide off. autohide_behavior
    # (wait_time 1000, transition_time 200, handle_size 4, unhide_delay 200) is
    # left at COSMIC's defaults — tune there if the reveal feels slow.
    "com.system76.CosmicPanel.Dock" = {
      version = 1;
      entries = {
        autohide = ronEnum "Always";

        # macOS keeps the dock to applications. COSMIC ships it holding the
        # launcher, workspaces and app-library buttons too; app-library stays
        # available as the Nix logo on the panel, and workspaces comes off the
        # bar entirely (gesture and keybind still reach it). That leaves the
        # pinned/running app list and the minimize tray.
        plugins_center = ronOptional [
          "com.system76.CosmicAppList"
          "com.system76.CosmicAppletMinimize"
        ];

        # Detach the dock from the screen edge, so its existing
        # border_radius reads as a floating slab the way macOS's does.
        anchor_gap = true;
      };
    };

    # macOS menu-bar layout: the Apple menu at the far left, the clock at the
    # far right. COSMIC centers the clock and puts the app-library button
    # second, so both move.
    "com.system76.CosmicPanel.Panel" = {
      version = 1;
      entries = {
        plugins_center = ronOptional null;
        plugins_wings = ronOptional {
          __type = "tuple";
          value = [
            # Left wing: the Nix logo alone, in the Apple menu's corner. The
            # workspaces button that shipped beside it is gone - macOS has
            # app menus there, and COSMIC has no equivalent to put in its
            # place, so an empty run of bar is the closer match. Workspaces
            # stay reachable by gesture and keybind.
            [ "com.system76.CosmicPanelAppButton" ]
            [
              "com.system76.CosmicAppletNetwork"
              "com.system76.CosmicAppletBattery"
              "com.system76.CosmicAppletTime"
              "com.system76.CosmicAppletPower"
            ]
          ];
        };
      };
    };
  };

  # Reproduces cosmic-manager modules/panels.nix's own restartCosmicPanel hook,
  # which it only installs when the `panels` option is used. cosmic-session
  # respawns the panel immediately.
  home.activation.restartCosmicPanel = lib.hm.dag.entryAfter [ "configureCosmic" ] ''
    run ${lib.getExe pkgs.killall} .cosmic-panel-wrapped || true
  '';

  # Puts the NixOS logo where macOS puts the Apple logo. The name to shadow is
  # com.system76.CosmicAppLibrary, NOT the CosmicPanelAppButton icon named in
  # the button's own .desktop: that .desktop runs
  # `cosmic-panel-button com.system76.CosmicAppLibrary`, and the button renders
  # the icon of the app id it is passed rather than its own.
  #
  # Written into two themes because hicolor alone did not win: the active theme
  # is WhiteSur-dark (home/linux/cosmic/theme.nix), and a theme's own
  # directories are searched before anything it inherits. WhiteSur-dark lists
  # apps/scalable in its index.theme Directories and ships no icon by this
  # name, so a file dropped there under $XDG_DATA_HOME merges into the theme
  # and takes precedence. The hicolor copy stays as the fallback for whatever
  # resolves outside the active theme.
  #
  # The white snowflake rather than the colored one, to read as a monochrome
  # menu-bar glyph — nix-snowflake.svg sits beside it in the same package if
  # the colored version is wanted instead.
  xdg.dataFile =
    let
      nixLogo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
      iconName = "com.system76.CosmicAppLibrary.svg";
    in
    {
      "icons/WhiteSur-dark/apps/scalable/${iconName}".source = nixLogo;
      "icons/hicolor/scalable/apps/${iconName}".source = nixLogo;
    };
}
