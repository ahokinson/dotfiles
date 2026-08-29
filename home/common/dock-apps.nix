# Single source of truth for the pinned dock/panel apps, in display order.
# That order is alphabetical, which is exactly how Nix iterates an attrset,
# so the attrset itself is the ordered list. Referenced by
# modules/darwin/system (dock.persistent-apps, .app bundle names) and
# home/linux/cosmic/panel.nix (every COSMIC host: app-list favorites,
# .desktop ids with the extension stripped, and the generated icon set).
# Plain data, not a NixOS/home-manager module. Each consumer maps over the
# values and builds its own platform-specific id format from these fields.
#
# linuxIconName is the desktop entry's Icon= key and is deliberately stored
# rather than derived from linuxDesktopId: the two only coincide for ghostty.
# Signal ships signal.desktop with Icon=signal-desktop, and Zen ships
# zen-beta.desktop with Icon=zen-browser.
#
# simpleIcon/hue feed home/common/icons.nix - the glyph's basename in
# simple-icons and the palette.nix color it's tinted with.
#
# pinned defaults to true (via `app.pinned or true`) and is only declared
# where an entry opts out - every app here still gets the generated icon
# either way, pinning only controls the dock/panel favorites list.
{
  ghostty = {
    darwinApp = "Ghostty.app";
    linuxDesktopId = "com.mitchellh.ghostty.desktop";
    linuxIconName = "com.mitchellh.ghostty";
    simpleIcon = "ghostty";
    hue = "mauve";
  };
  signal = {
    darwinApp = "Signal.app";
    linuxDesktopId = "signal.desktop";
    linuxIconName = "signal-desktop";
    simpleIcon = "signal";
    hue = "blue";
  };
  # simpleIcon is discord, not vesktop: simple-icons has no vesktop glyph,
  # and the Discord mark is what the app is. Not pinned - installed and
  # icon-themed like everything else here, just not in the dock/panel.
  vesktop = {
    darwinApp = "Vesktop.app";
    linuxDesktopId = "vesktop.desktop";
    linuxIconName = "vesktop";
    simpleIcon = "discord";
    hue = "lavender";
    pinned = false;
  };
  zen = {
    darwinApp = "Zen Browser (Beta).app";
    linuxDesktopId = "zen-beta.desktop";
    linuxIconName = "zen-browser";
    simpleIcon = "zenbrowser";
    hue = "peach";
  };
}
