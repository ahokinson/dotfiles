# Single source of truth for the two pinned dock/panel apps. Referenced by
# modules/darwin/system (dock.persistent-apps, .app bundle names) and
# home/linux/cosmic/panel.nix (every COSMIC host: app-list favorites,
# .desktop ids with the extension stripped). Plain data, not a
# NixOS/home-manager module. Each consumer imports it and builds its own
# platform-specific id format from these two fields.
#
# A plain attrset, not a list. Consumers reference `.zen`/`.ghostty` by name
# and build their own ordered list, since Nix attrset iteration order isn't
# the display order these dock/panel entries need.
{
  zen = {
    darwinApp = "Zen Browser (Beta).app";
    linuxDesktopId = "zen-beta.desktop";
  };
  ghostty = {
    darwinApp = "Ghostty.app";
    linuxDesktopId = "com.mitchellh.ghostty.desktop";
  };
}
