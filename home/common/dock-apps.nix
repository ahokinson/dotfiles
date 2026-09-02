# Dock and panel apps in display order, which is alphabetical because that is
# how Nix iterates an attrset. Plain data, not a module; read by
# modules/darwin/system, home/linux/cosmic/panel.nix and home/common/icons.nix.
#
# linuxIconName is the desktop entry's Icon= key; it matches linuxDesktopId
# only for ghostty. pinned defaults true (`app.pinned or true`), and opting
# out drops the app from the dock, not from the generated icon set.
# vendoredIcon marks simpleIcon as a filename under home/common/_files
# instead of a glyph in the simple-icons input (see slack; the glyph itself
# lives in home/linux/icons/default.nix's mkIcon call).
# asahiLinuxDesktopId overrides linuxDesktopId on the Asahi hosts, for an app
# whose Linux build differs by CPU arch.
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
  slack = {
    darwinApp = "Slack.app";
    linuxDesktopId = "slack.desktop";
    linuxIconName = "slack";
    # Asahi hosts run slacky instead (home/linux/packages.nix); its .desktop
    # id differs from the real client's.
    asahiLinuxDesktopId = "slacky.desktop";
    # simple-icons dropped this glyph (a Salesforce trademark request, since
    # Salesforce owns Slack); vendored from before the removal instead.
    simpleIcon = "slack";
    vendoredIcon = true;
    hue = "green";
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
