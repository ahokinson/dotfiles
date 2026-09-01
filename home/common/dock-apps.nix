# Dock and panel apps in display order, which is alphabetical because that is
# how Nix iterates an attrset. Plain data, not a module; read by
# modules/darwin/system, home/linux/cosmic/panel.nix and home/common/icons.nix.
#
# linuxIconName is the desktop entry's Icon= key; it matches linuxDesktopId
# only for ghostty. pinned defaults true (`app.pinned or true`), and opting
# out drops the app from the dock, not from the generated icon set.
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
  # simple-icons has no vesktop glyph, hence the Discord mark.
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
