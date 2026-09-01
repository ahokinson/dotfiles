# Both panels are declared in full, every field cosmic-panel reads, plus the
# registry naming them. This is load-bearing, not thoroughness:
# cosmic-panel deserializes com.system76.CosmicPanel.<name> as one struct, and
# a single missing field makes it discard the config, fall back to Default and
# persist that back. A partial config survives only while a complete one is
# already on disk, so a fresh install silently resets everything here.
# Fields this repo has no opinion on hold cosmic-panel 1.6's own defaults.
#
# Complete against 1.6's schema only. A release that adds a field makes this
# partial again, and the first cold start after that upgrade resets it.
#
# wayland.desktopManager.cosmic.panels is avoided for the same reason:
# cosmic-manager's cleanNullsExceptOptional drops every defaultNullOpts null,
# emitting exactly the partial config above. It also still types autohide as
# the pre-1.6 Option<AutoHide> and has no option for border_radius, padding,
# spacing, exclusive_zone, layer, keyboard_interactivity, autohover_delay_ms,
# padding_overlap, keep_style_on_maximize, size_center or size_wings. Its
# restartCosmicPanel hook only fires when `panels` is set, so that is
# reproduced by hand below.
#
# Favorite ids are each app's .desktop filename, extension stripped.
{
  selfPath,
  lib,
  pkgs,
  ...
}:
let
  # vesktop opts out of pinning (home/common/dock-apps.nix).
  pinnedApps = builtins.filter (app: app.pinned or true) (
    builtins.attrValues (import (selfPath "home/common/dock-apps.nix"))
  );
  stripDesktopSuffix = id: lib.removeSuffix ".desktop" id;

  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;

  # The 13 of 24 panel fields that agree on both bars, all at cosmic-panel
  # 1.6's defaults.
  sharedPanelEntries = {
    # Only read when autohide is not Never, so inert on the top panel.
    autohide_behavior = {
      wait_time = 1000;
      transition_time = 200;
      handle_size = 4;
      unhide_delay = 200;
    };
    autohover_delay_ms = ronOptional 500;
    background = ronEnum "ThemeDefault";
    keep_style_on_maximize = false;
    keyboard_interactivity = ronEnum "OnDemand";
    layer = ronEnum "Top";

    # The dock's anchor_gap needs a non-zero margin here to open a real gap.
    # Left at COSMIC's 0; raise it if the dock should visibly float.
    margin = 0;

    opacity = 1.0;
    output = ronEnum "All";
    padding_overlap = 0.5;
    size_center = ronOptional null;
    size_wings = ronOptional null;
    spacing = 0;
  };
in
{
  # cosmic-manager's switch, not services.desktopManager.cosmic.enable.
  wayland.desktopManager.cosmic.enable = true;

  wayland.desktopManager.cosmic.applets."app-list".settings.favorites = map (
    app: stripDesktopSuffix app.linuxDesktopId
  ) pinnedApps;

  # Weekday, month, day, 24-hour time with seconds, as the macOS menu bar.
  wayland.desktopManager.cosmic.applets."time".settings = {
    military_time = true;
    show_seconds = true;
  };

  # Icons rather than words, so the leftmost button reads as a logo.
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
    # Which bars cosmic-panel spawns. COSMIC's stock pair, declared so a
    # fresh install bootstraps nothing itself.
    "com.system76.CosmicPanel" = {
      version = 1;
      entries.entries = [
        "Panel"
        "Dock"
      ];
    };

    "com.system76.CosmicPanel.Dock" = {
      version = 1;
      entries = sharedPanelEntries // {
        name = "Dock";
        anchor = ronEnum "Bottom";
        autohide = ronEnum "Always";

        # Detaches the dock from the screen edge so border_radius shows.
        anchor_gap = true;

        # Applications only. COSMIC also ships the launcher, workspaces and
        # app-library here; app-library moves to the panel as the Nix logo,
        # workspaces comes off entirely (gesture and keybind still reach it).
        plugins_center = ronOptional [
          "com.system76.CosmicAppList"
          "com.system76.CosmicAppletMinimize"
        ];
        plugins_wings = ronOptional null;

        border_radius = 12;
        exclusive_zone = false;
        expand_to_edges = false;
        padding = 4;
        size = ronEnum "L";
      };
    };

    "com.system76.CosmicPanel.Panel" = {
      version = 1;
      entries = sharedPanelEntries // {
        name = "Panel";
        anchor = ronEnum "Top";
        autohide = ronEnum "Never";
        anchor_gap = false;

        # Logo far left, clock far right. COSMIC centers the clock and puts
        # app-library second, so both move.
        plugins_center = ronOptional null;
        plugins_wings = ronOptional {
          __type = "tuple";
          value = [
            [ "com.system76.CosmicPanelAppButton" ]
            [
              "com.system76.CosmicAppletNetwork"
              "com.system76.CosmicAppletBattery"
              "com.system76.CosmicAppletTime"
              "com.system76.CosmicAppletPower"
            ]
          ];
        };

        border_radius = 0;
        exclusive_zone = true;
        expand_to_edges = true;
        padding = 0;
        size = ronEnum "XS";
      };
    };
  };

  # cosmic-manager only wires its own restartCosmicPanel hook when `panels`
  # is used. cosmic-session respawns the panel immediately.
  home.activation.restartCosmicPanel = lib.hm.dag.entryAfter [ "configureCosmic" ] ''
    run ${lib.getExe pkgs.killall} .cosmic-panel-wrapped || true
  '';

  # The logo and the pinned apps' icons come from home/linux/icons.
}
