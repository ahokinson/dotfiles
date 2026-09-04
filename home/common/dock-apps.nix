# Dock and panel apps in display order, which is alphabetical because that is
# how Nix iterates an attrset. Plain data, not a module; read by
# modules/darwin/system, home/linux/cosmic/panel.nix and home/common/icons.nix.
#
# linuxIconName is the desktop entry's Icon= key; it matches linuxDesktopId
# only for ghostty. pinned defaults false (`app.pinned or false`), so opting
# in is what puts an app in the dock; everything listed here gets a generated
# icon either way.
# vendoredIcon marks simpleIcon as a filename under home/common/_files
# instead of a glyph in the simple-icons input (see slack; the glyph itself
# lives in home/linux/icons/default.nix's mkIcon call).
# asahiLinuxDesktopId overrides linuxDesktopId on the Asahi hosts, for an app
# whose Linux build differs by CPU arch. extraLinuxIconNames files the same
# generated tile under further Icon= keys; a host only ever has one of those
# builds installed, so carrying both names beats branching per arch.
# darwinApp is optional (see protonvpn): modules/darwin/system/defaults.nix
# skips pinning any app that omits it, for one with no macOS build here.
{
  ghostty = {
    darwinApp = "Ghostty.app";
    linuxDesktopId = "com.mitchellh.ghostty.desktop";
    linuxIconName = "com.mitchellh.ghostty";
    simpleIcon = "ghostty";
    hue = "mauve";
    pinned = true;
  };
  # Linux only: pkgs.obs-studio's meta.platforms has no darwin entry, and
  # there's no cask here standing in for one, so darwinApp stays unset.
  obs = {
    linuxDesktopId = "com.obsproject.Studio.desktop";
    linuxIconName = "com.obsproject.Studio";
    simpleIcon = "obsstudio";
    hue = "red";
  };
  # Linux only: pkgs.proton-vpn's meta.platforms has no darwin entry, and
  # there's no cask here standing in for one, so darwinApp stays unset.
  protonvpn = {
    linuxDesktopId = "proton.vpn.app.gtk.desktop";
    linuxIconName = "proton-vpn-logo";
    simpleIcon = "protonvpn";
    hue = "lavender";
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
    # id and its Icon= key both differ from the real client's.
    asahiLinuxDesktopId = "slacky.desktop";
    extraLinuxIconNames = [ "slacky" ];
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
  };
  zen = {
    darwinApp = "Zen Browser (Beta).app";
    linuxDesktopId = "zen-beta.desktop";
    linuxIconName = "zen-browser";
    simpleIcon = "zenbrowser";
    hue = "peach";
    pinned = true;
  };
}
