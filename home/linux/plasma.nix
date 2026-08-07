# KDE Plasma 6 desktop wallpaper via plasma-manager - NixOS only. Everything
# else that used to live here (colorScheme, windowDecorations, fonts,
# window-rules, kwinrc, kscreenlocker) moved to plasma-theme.nix, which is
# shared with Asahi; the panel lives in plasma-panel.nix, also shared. This
# file is what's left: the one piece that actually needs a NixOS host.
#
# workspace.wallpaper runs as a plasma-manager desktopScript rather than
# home/linux/wallpaper.nix's `home.activation` alone, because that activation
# runs inside the home-manager-anders systemd *system* service during
# `nixos-rebuild switch`, which lacks the live session's D-Bus bus - the
# write silently doesn't land. desktopScripts run at login instead, when a
# live session is guaranteed. wallpaper.nix's approach stays for Asahi, which
# imports plasma-panel.nix and plasma-theme.nix but not this file.
{ selfPath, ... }:
let
  wallpaper = selfPath "home/common/_files/wallpaper-frappe-base.png";
in
{
  programs.plasma.workspace.wallpaper = wallpaper;
}
