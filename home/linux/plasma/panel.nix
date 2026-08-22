# Shared KDE Plasma panel via plasma-manager — every Linux/Plasma host,
# NixOS and Asahi Fedora alike. plasma-manager writes config by editing
# Plasma's ini files directly rather than linking into the live Qt/Plasma
# process, so — unlike catppuccin-qt.nix's Kvantum/Qt platform-theme
# plugins — it's safe to run against Asahi's Fedora-built Plasma too.
{ pkgs, selfPath, osConfig ? null, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  dockApps = import (selfPath "home/common/dock-apps.nix");

  # osConfig is a specialArg home-manager injects only when wired in as a
  # NixOS module - present for framework13-amd-ryzen, absent for the
  # standalone Asahi profile. Has to be taken as a function argument like
  # this, not tested via `config`'s own option tree.
  isNixOS = osConfig != null;
  kickoffIcon =
    if isNixOS
    then "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg"
    else selfPath "home/common/_files/asahi-apple.svg";
in
{
  programs.plasma = {
    enable = true;

    # Reasserts these values on every activation, not just first apply -
    # otherwise a manual System Settings change drifts away from this file.
    overrideConfig = true;

    # Mirrors the macOS Dock (modules/darwin/system's dock.orientation,
    # dock.autohide, dock.tilesize, dock.persistent-apps): bottom, floating,
    # auto-hiding, icon-only tasks with the same two apps pinned.
    #
    # height is NOT dock.tilesize. tilesize is macOS's icon size; this is
    # the panel's full thickness, and a floating panel spends roughly 12px
    # of it on margin. height runs above tilesize (44 vs 32) to land on the
    # same icon size — change both together or they drift apart.
    panels = [
      {
        location = "bottom";
        floating = true;
        hiding = "autohide";
        height = 44;
        widgets = [
          # NixOS logo on NixOS, Asahi Linux logo on Asahi - the one spot
          # Plasma shows a distro logo, same idea as the macOS Apple menu.
          { kickoff = { icon = kickoffIcon; }; }
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = with dockApps; [
                "applications:${zen.linuxDesktopId}"
                "applications:${ghostty.linuxDesktopId}"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          # Matches the macOS menu bar clock (modules/darwin/system's
          # menuExtraClock.*): 24h time with seconds, a custom "Wed Aug 5"
          # date inline, and a fixed compact font instead of Plasma's
          # default of scaling the clock to fill this panel's height.
          {
            digitalClock = {
              date.enable = true;
              date.position = "besideTime";
              date.format = { custom = "ddd MMM d"; };
              time.format = "24h";
              time.showSeconds = "always";
              font = {
                family = sharedFonts.generalFamily;
                size = sharedFonts.pointSize - 2;
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}
