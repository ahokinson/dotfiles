# A real child theme of WhiteSur-dark carrying this repo's app icons, and the
# selected theme for both toolkits: GTK's gtk.iconTheme and COSMIC's
# appearance.toolkit.icon_theme are separate settings that have to agree.
#
# Shadowing files into ~/.local/share/icons/WhiteSur-dark is the obvious
# approach and does not work: cosmic-freedesktop-icons searches
# $XDG_DATA_DIRS before $XDG_DATA_HOME, the reverse of the icon-theme spec
# and GTK, and the Nix profile is on $XDG_DATA_DIRS. Every name WhiteSur
# already ships answers from there first. Inheriting sidesteps the ordering:
# this theme is selected, and Inherits covers what it does not define.
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

  # osConfig is always set here, so hardware.asahi.enable can distinguish the
  # Apple Silicon hosts from framework13-amd-ryzen.
  isApple = osConfig.hardware.asahi.enable or false;

  # Shadows com.system76.CosmicAppLibrary rather than the panel button's own
  # icon name: the button renders whatever app id it is passed.
  logo =
    if isApple then
      selfPath "home/common/_files/asahi-apple.svg"
    else
      "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # apps@2x/scalable is under both keys on purpose: the spec wants a Scale=2
  # directory in ScaledDirectories, but implementations reading only
  # Directories would never see it. It cannot be skipped either, since
  # WhiteSur declares its own and HiDPI resolves that ahead of apps/scalable.
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
      install app.linuxIconName (mkIcon (
        {
          name = app.linuxIconName;
          glyph = app.simpleIcon;
          inherit (app) hue;
        }
        // lib.optionalAttrs (app.vendoredIcon or false) {
          glyphDir = selfPath "home/common/_files";
        }
      ))
    ) (builtins.attrValues dockApps)}
  '';
in
{
  gtk.iconTheme = {
    name = themeName;
    inherit package;
  };

  # COSMIC's toolkit defaults to the "Cosmic" theme independently of GTK, so
  # without this its own apps keep their stock icons.
  wayland.desktopManager.cosmic.appearance.toolkit.icon_theme = themeName;

  # The parent theme must stay installed for Inherits to resolve.
  home.packages = [ pkgs.whitesur-icon-theme ];
}
