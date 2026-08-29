# WhiteSur-dark with this repo's Catppuccin icons layered on top, built as a
# real child theme and made the active one. Owns both toolkits' notion of
# which icon theme is in use: GTK's (gtk.iconTheme) and COSMIC's own
# (appearance.toolkit.icon_theme), which are separate settings that have to
# agree.
#
# Deliberately not done by dropping files into
# ~/.local/share/icons/WhiteSur-dark, which is the obvious approach and does
# not work under COSMIC. Its resolver (cosmic-freedesktop-icons, the fork
# libcosmic uses) builds its search list as $XDG_DATA_DIRS, then
# $XDG_DATA_HOME, then $HOME/.icons - $XDG_DATA_DIRS first, the reverse of
# both the icon-theme spec and GTK. The Nix profile is on $XDG_DATA_DIRS, so
# the WhiteSur-dark installed there answers first for every name it already
# ships and a home-directory copy is never reached. WhiteSur ships all three
# pinned apps, so all three lost; only the app-library logo won, and only
# because WhiteSur has no icon by that name to answer with.
#
# Inheriting instead of shadowing removes the ordering question entirely:
# this theme is the one selected, its own icons are found in it, and
# everything it does not define falls through to WhiteSur-dark by Inherits.
{
  inputs,
  selfPath,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  dockApps = import (selfPath "home/common/dock-apps.nix");
  inherit (import (selfPath "home/common/icons.nix") { inherit inputs pkgs selfPath; }) mkIcon;

  themeName = "WhiteSur-dark-catppuccin";

  # Every host here is a NixOS module, so osConfig is always set - the logo
  # keys off hardware.asahi.enable to tell the Apple Silicon hosts
  # (bookpro14-m1-pro, studio-m1-max) apart from framework13-amd-ryzen.
  isApple = osConfig.hardware.asahi.enable or false;

  # Goes where macOS puts the Apple logo. Shadows com.system76.CosmicAppLibrary
  # rather than the panel button's own icon name, since the button renders
  # whatever app id it is passed.
  logo =
    if isApple then
      selfPath "home/common/_files/asahi-apple.svg"
    else
      "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # apps@2x/scalable is listed under both keys on purpose. ScaledDirectories
  # is where the spec wants a Scale=2 directory, but implementations that
  # only read Directories would then never see it - and skipping it is not an
  # option here, since WhiteSur declares its own apps@2x/scalable and a HiDPI
  # output resolves that ahead of apps/scalable. Same SVG in both; it is
  # vector either way.
  indexTheme = pkgs.writeText "index.theme" ''
    [Icon Theme]
    Name=${themeName}
    Comment=WhiteSur-dark with Catppuccin Frappe icons for the pinned apps
    Inherits=WhiteSur-dark,hicolor
    Directories=apps/scalable,apps@2x/scalable
    ScaledDirectories=apps@2x/scalable

    [apps/scalable]
    Size=64
    MinSize=8
    MaxSize=512
    Context=Applications
    Type=Scalable

    [apps@2x/scalable]
    Size=64
    Scale=2
    MinSize=8
    MaxSize=512
    Context=Applications
    Type=Scalable
  '';

  install = name: source: ''
    install -Dm444 ${source} "$dir/apps/scalable/${name}.svg"
    install -Dm444 ${source} "$dir/apps@2x/scalable/${name}.svg"
  '';

  package = pkgs.runCommand "whitesur-dark-catppuccin-icon-theme" { } ''
    dir="$out/share/icons/${themeName}"
    install -Dm444 ${indexTheme} "$dir/index.theme"

    ${install "com.system76.CosmicAppLibrary" logo}
    ${lib.concatMapStrings (
      app:
      install app.linuxIconName (mkIcon {
        name = app.linuxIconName;
        glyph = app.simpleIcon;
        inherit (app) hue;
      })
    ) (builtins.attrValues dockApps)}
  '';
in
{
  gtk.iconTheme = {
    name = themeName;
    inherit package;
  };

  # COSMIC's own toolkit defaults to the "Cosmic" icon theme, independent of
  # GTK's. Without this, COSMIC Files/Settings keep their stock icons while
  # GTK apps use the theme above.
  wayland.desktopManager.cosmic.appearance.toolkit.icon_theme = themeName;

  # The parent theme has to stay installed for Inherits to resolve.
  home.packages = [ pkgs.whitesur-icon-theme ];
}
