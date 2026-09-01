# COSMIC's panel/dock split, shared by every NixOS host. Both panels are
# declared in full - every field cosmic-panel reads - along with the registry
# that names them, rather than as a delta over stock.
#
# Writing the complete key set is load-bearing. cosmic-panel deserializes
# com.system76.CosmicPanel.<name> as a single struct: if any field is missing
# it discards the whole config, falls back to Default, and persists that back
# over whatever was there. A partial config therefore survives only when the
# panel is already running with a complete one on disk - true of every rebuild
# except the first. On a fresh install home-manager activation runs before
# cosmic-panel has ever started (the restartCosmicPanel hook below logs "no
# process found"), so the panel's first start silently resets every key set
# here. cosmic-comp is the contrast: it merges per-field, which is why
# compositor.nix can stay a delta.
#
# Fields this repo has no opinion on are transcribed from what cosmic-panel
# 1.6 writes as its own defaults. Pinning them is the point - an undeclared
# field is one COSMIC owns.
#
# Caveat: complete against COSMIC 1.6's schema. A release that adds a panel
# field makes this partial again, and the first cold start after that upgrade
# resets it until the next rebuild.
#
# Still deliberately avoids wayland.desktopManager.cosmic.panels, now for two
# reasons. It replaces COSMIC's entire panel registry, and cosmic-manager's
# modules/files.nix runs entries through cleanNullsExceptOptional, dropping
# every field left at its defaultNullOpts null - so it emits a partial config
# too, the exact failure above. Its panelSubmodule also still types autohide
# as the pre-1.6 Option<AutoHide> struct, where 1.6 wants an enum plus a
# separate autohide_behavior, and has no option at all for border_radius,
# padding, spacing, exclusive_zone, layer, keyboard_interactivity,
# autohover_delay_ms, padding_overlap, keep_style_on_maximize, size_center or
# size_wings. cosmic-manager only wires its restartCosmicPanel activation hook
# when `panels` is set, so that hook is reproduced by hand below.
#
# Favorite ids are each app's .desktop filename with the extension stripped.
{
  selfPath,
  lib,
  pkgs,
  ...
}:
let
  # Pinned apps only - vesktop opts out (home/common/dock-apps.nix), so it's
  # installed and icon-themed but not in the app-list favorites.
  pinnedApps = builtins.filter (app: app.pinned or true) (
    builtins.attrValues (import (selfPath "home/common/dock-apps.nix"))
  );
  stripDesktopSuffix = id: lib.removeSuffix ".desktop" id;

  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;

  # The 13 of the 24 panel fields that hold the same value on both bars. Each
  # is cosmic-panel 1.6's own default; none is a preference of this repo's.
  sharedPanelEntries = {
    # Timings for the hide/unhide animation. Only read when autohide is not
    # Never, so this is inert on the top panel.
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

    # The dock sets anchor_gap, which cosmic-manager documents as needing a
    # non-zero margin to actually open a gap. Kept at COSMIC's 0 all the same:
    # this is the value framework13 has always run, and parity across hosts is
    # what this file is for. Raise it here if the dock should visibly float.
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
  # cosmic-manager's own master switch (home-manager level) - distinct from
  # services.desktopManager.cosmic.enable (NixOS level).
  wayland.desktopManager.cosmic.enable = true;

  wayland.desktopManager.cosmic.applets."app-list".settings.favorites = map (
    app: stripDesktopSuffix app.linuxDesktopId
  ) pinnedApps;

  # macOS menu-bar clock: weekday + month + day, 24-hour time with seconds.
  wayland.desktopManager.cosmic.applets."time".settings = {
    military_time = true;
    show_seconds = true;
  };

  # Render the top panel's buttons as icons instead of words, so the
  # leftmost one reads as a logo the way macOS's Apple menu does.
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
    # The registry cosmic-panel reads to decide which bars to spawn. Declared
    # so a fresh install needs nothing bootstrapped by the panel itself; the
    # value is COSMIC's stock pair.
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

        # Detaches the dock from the screen edge, so its border_radius
        # reads as a floating slab the way macOS's does.
        anchor_gap = true;

        # macOS keeps the dock to applications. COSMIC ships it holding the
        # launcher, workspaces and app-library buttons too; app-library
        # stays on the panel as the Nix logo, workspaces comes off the bar
        # entirely (gesture and keybind still reach it).
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

        # macOS menu-bar layout: Apple menu far left, clock far right. COSMIC
        # centers the clock and puts app-library second, so both move.
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

  # Reproduces cosmic-manager's own restartCosmicPanel hook (only wired
  # automatically when `panels` is used); cosmic-session respawns the panel
  # immediately.
  home.activation.restartCosmicPanel = lib.hm.dag.entryAfter [ "configureCosmic" ] ''
    run ${lib.getExe pkgs.killall} .cosmic-panel-wrapped || true
  '';

  # The panel button's logo and the pinned apps' icons both come from
  # home/linux/icons, which carries them in the active icon theme
  # rather than shadowing files under ~/.local/share/icons.
}
