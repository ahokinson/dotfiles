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
  palette = import (selfPath "home/common/palette.nix");

  themeName = "WhiteSur-dark-catppuccin";

  isApple = import (selfPath "home/common/is-apple.nix") { inherit osConfig; };

  # Both logos below ship their own brand colors; swapped hex-for-hex onto
  # Mocha so the app-library button matches the rest of the icon theme.
  recolor =
    replacements: source:
    pkgs.writeText (baseNameOf source) (
      lib.replaceStrings (builtins.attrNames replacements) (builtins.attrValues replacements) (
        builtins.readFile source
      )
    );

  # Shadows com.system76.CosmicAppLibrary rather than the panel button's own
  # icon name: the button renders whatever app id it is passed.
  logo =
    if isApple then
      recolor {
        "#2c2c2c" = palette.crust; # darkest facet
        "#530900" = palette.mantle; # small dark sliver
        "#d3506f" = palette.red;
        "#a61200" = palette.maroon;
        "#00a67c" = palette.teal;
        "#edbb60" = palette.yellow;
        "#ffffff" = palette.text;
        "#96caf3" = palette.sapphire;
      } (selfPath "home/common/_files/asahi-apple.svg")
    else
      recolor {
        # linearGradient5562 (light triangles), 3 stops flattened to one tone
        "#699ad7" = palette.sapphire;
        "#7eb1dd" = palette.sapphire;
        "#7ebae4" = palette.sapphire;
        # linearGradient5053 (dark triangles), 3 stops flattened to one tone
        "#415e9a" = palette.blue;
        "#4a6baf" = palette.blue;
        "#5277c3" = palette.blue;
      } "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # apps@2x/scalable is under both keys on purpose: the spec wants a Scale=2
  # directory in ScaledDirectories, but implementations reading only
  # Directories would never see it. It cannot be skipped either, since
  # WhiteSur declares its own and HiDPI resolves that ahead of apps/scalable.
  indexTheme = pkgs.writeText "index.theme" ''
    [Icon Theme]
    Name=${themeName}
    Comment=WhiteSur-dark with Catppuccin Mocha icons for this repo's apps
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
      let
        tile = mkIcon (
          {
            name = app.linuxIconName;
            glyph = app.simpleIcon;
            inherit (app) hue;
          }
          // lib.optionalAttrs (app.vendoredIcon or false) {
            glyphDir = selfPath "home/common/_files";
          }
        );
      in
      # One generated tile, filed under every Icon= key a desktop entry for
      # this app could use (home/common/dock-apps.nix's extraLinuxIconNames)
      # — a host only ever has one of those builds installed, so this beats
      # branching the filename per arch.
      lib.concatMapStrings (name: install name tile) (
        [ app.linuxIconName ] ++ (app.extraLinuxIconNames or [ ])
      )
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
