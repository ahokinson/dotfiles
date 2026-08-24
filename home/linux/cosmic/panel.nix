# COSMIC's default panel/dock split, shared by every NixOS host; this only
# overrides what differs from stock:
# pinned-app favorites (mirroring modules/darwin/system's
# dock.persistent-apps), panel icon presentation, and dock/panel layout via
# configFile.
#
# Deliberately doesn't touch wayland.desktopManager.cosmic.panels. Setting
# it replaces COSMIC's entire panel registry (checked against
# cosmic-manager's modules/panels.nix), silently dropping the stock top
# panel. configFile writes individual keys instead, without touching the
# registry. cosmic-manager only wires its restartCosmicPanel activation hook
# when `panels` is set, so that hook is reproduced by hand below.
#
# Favorite ids are each app's .desktop filename with the extension stripped.
{ selfPath, lib, pkgs, osConfig ? null, ... }:
let
  dockApps = import (selfPath "home/common/dock-apps.nix");
  stripDesktopSuffix = id: lib.removeSuffix ".desktop" id;

  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;

  # Every host here is a NixOS module, so osConfig is always set - the
  # logo instead keys off hardware.asahi.enable to tell Apple Silicon hosts
  # (bookpro14-m1-pro, studio-m1-max) apart from framework13-amd-ryzen.
  isApple = osConfig.hardware.asahi.enable or false;
in
{
  # cosmic-manager's own master switch (home-manager level) - distinct from
  # services.desktopManager.cosmic.enable (NixOS level).
  wayland.desktopManager.cosmic.enable = true;

  wayland.desktopManager.cosmic.applets."app-list".settings.favorites =
    with dockApps; [
      (stripDesktopSuffix zen.linuxDesktopId)
      (stripDesktopSuffix ghostty.linuxDesktopId)
    ];

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
    "com.system76.CosmicPanel.Dock" = {
      version = 1;
      entries = {
        autohide = ronEnum "Always";

        # macOS keeps the dock to applications. COSMIC ships it holding the
        # launcher, workspaces and app-library buttons too; app-library
        # stays on the panel as the Nix logo, workspaces comes off the bar
        # entirely (gesture and keybind still reach it).
        plugins_center = ronOptional [
          "com.system76.CosmicAppList"
          "com.system76.CosmicAppletMinimize"
        ];

        # Detaches the dock from the screen edge, so its border_radius
        # reads as a floating slab the way macOS's does.
        anchor_gap = true;
      };
    };

    # macOS menu-bar layout: Apple menu far left, clock far right. COSMIC
    # centers the clock and puts app-library second, so both move.
    "com.system76.CosmicPanel.Panel" = {
      version = 1;
      entries = {
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
      };
    };
  };

  # Reproduces cosmic-manager's own restartCosmicPanel hook (only wired
  # automatically when `panels` is used); cosmic-session respawns the panel
  # immediately.
  home.activation.restartCosmicPanel = lib.hm.dag.entryAfter [ "configureCosmic" ] ''
    run ${lib.getExe pkgs.killall} .cosmic-panel-wrapped || true
  '';

  # Puts the host's own logo where macOS puts the Apple logo: Asahi Linux
  # logo on the Apple Silicon hosts, NixOS snowflake on framework13. Shadows
  # com.system76.CosmicAppLibrary, not the button's own icon name (the
  # button renders whatever app id it's passed). Written into both
  # WhiteSur-dark and hicolor: the active theme's own directories are
  # searched first, so the WhiteSur-dark copy wins; hicolor is the fallback
  # for anything resolving outside the active theme.
  xdg.dataFile =
    let
      logo =
        if isApple
        then selfPath "home/common/_files/asahi-apple.svg"
        else "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      iconName = "com.system76.CosmicAppLibrary.svg";
    in
    {
      "icons/WhiteSur-dark/apps/scalable/${iconName}".source = logo;
      "icons/hicolor/scalable/apps/${iconName}".source = logo;
    };
}
