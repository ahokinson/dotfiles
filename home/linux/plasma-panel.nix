# Shared KDE Plasma panel via plasma-manager - every Linux/Plasma host, NixOS
# and Asahi Fedora alike. Split out of plasma.nix (which now holds only the
# NixOS-specific theme/workspace/window-rules pieces) so this same panel can
# be imported by the standalone Asahi home-manager profile too. plasma-manager
# writes config by editing Plasma's ini files directly rather than linking
# into the live Qt/Plasma process, so - unlike catppuccin-qt.nix's Kvantum/Qt
# platform-theme plugins - it's safe to run against Asahi's Fedora-built
# Plasma, not just a Nix-built one.
{ pkgs, selfPath, osConfig ? null, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # osConfig is a specialArg home-manager injects only when it's wired in as
  # a NixOS module - present (non-null) for framework13-amd-ryzen, absent
  # for the standalone Asahi profile. NB: home/linux/default.nix and
  # home/linux/packages.nix document this as `config ? osConfig`, but that
  # tests the wrong thing (config's own option tree, not the module's
  # special args) and is always false; osConfig has to be taken as a
  # function argument like this instead.
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

    # Mirrors the macOS Dock (modules/darwin/system.nix: dock.orientation,
    # dock.autohide, dock.tilesize, dock.persistent-apps) so both platforms
    # feel like the same bar: bottom, floating, auto-hiding, icon-only tasks
    # with the same two apps pinned.
    #
    # height is NOT dock.tilesize. tilesize is macOS's icon size; this is the
    # panel's full thickness, and a floating panel spends roughly 12px of it on
    # margin. So height runs above tilesize to land on the same icon size:
    # 44 here against tilesize 32. Change both together or they drift apart.
    panels = [
      {
        location = "bottom";
        floating = true;
        hiding = "autohide";
        height = 44;
        widgets = [
          # icon: the NixOS logo on NixOS, the Asahi Linux logo on Asahi -
          # the one spot Plasma shows a distro logo, same idea as the Apple
          # menu icon on the macOS side of this panel parity.
          { kickoff = { icon = kickoffIcon; }; }
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:zen-beta.desktop"
                "applications:com.mitchellh.ghostty.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          # Matches the macOS menu bar clock (modules/darwin/system.nix:
          # menuExtraClock.Show24Hour/ShowDate/IsAnalog) - 24h time with
          # seconds, a custom "Wed Aug 5" date inline rather than stacked
          # underneath, and a fixed compact font (smaller than the general UI
          # font, matching fonts.small below) instead of Plasma's default of
          # scaling the clock to fill this panel's 64px height.
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
