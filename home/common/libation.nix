{ pkgs, lib, selfPath, ... }:
let
  palette = import (selfPath "home/common/palette.nix");

  opaque = hex: "#FF" + builtins.substring 1 6 hex;
  tint = alphaHex: hex: "#" + alphaHex + builtins.substring 1 6 hex;

  # Avalonia's Fluent ColorPaletteResources (Avalonia.Themes.Fluent
  # 12.1.2's ColorPaletteResources.Properties.cs). ChromeWhite is left out,
  # keeping Avalonia's stock pure white.
  fluentColors = {
    Accent = opaque palette.mauve;
    AltHigh = opaque palette.crust;
    AltLow = opaque palette.surface2;
    AltMedium = opaque palette.surface0;
    AltMediumHigh = opaque palette.mantle;
    AltMediumLow = opaque palette.surface1;
    BaseHigh = opaque palette.text;
    # Drives ButtonBackground (SystemControlBackgroundBaseLowBrush) - the
    # default (non-accent) button has no border, so this is its only
    # visual affordance. surface1 read as too close to RegionColor/base to
    # look clickable; overlay0 gives it real separation.
    BaseLow = opaque palette.overlay0;
    BaseMedium = opaque palette.subtext0;
    BaseMediumHigh = opaque palette.subtext1;
    BaseMediumLow = opaque palette.overlay1;
    ChromeAltLow = opaque palette.surface0;
    ChromeBlackHigh = opaque palette.crust;
    ChromeBlackLow = tint "33" palette.crust;
    ChromeBlackMedium = opaque palette.base;
    ChromeBlackMediumLow = opaque palette.mantle;
    ChromeDisabledHigh = opaque palette.overlay0;
    ChromeDisabledLow = opaque palette.surface1;
    ChromeGray = opaque palette.overlay0;
    ChromeHigh = opaque palette.overlay1;
    ChromeLow = opaque palette.surface0;
    ChromeMedium = opaque palette.surface2;
    ChromeMediumLow = opaque palette.surface1;
    ErrorText = opaque palette.red;
    ListLow = opaque palette.surface0;
    ListMedium = opaque palette.surface1;
    RegionColor = opaque palette.base;
  };

  # Libation's own theme-dictionary brushes (App.axaml's Dark
  # ResourceDictionary keys).
  libationColors = {
    SeriesEntryGridBackgroundBrush = tint "4D" palette.surface2;
    ProcessQueueBookFailedBrush = tint "4D" palette.red;
    ProcessQueueBookCompletedBrush = tint "4D" palette.green;
    ProcessQueueBookCancelledBrush = tint "4D" palette.yellow;
    HyperlinkNew = opaque palette.blue;
    HyperlinkVisited = opaque palette.mauve;
    CancelRed = opaque palette.maroon;
    IconFill = opaque palette.text;
  };

  # ChardonnayTheme's ThemeColors field: Dictionary<ThemeVariant,
  # Dictionary<string, Color>>. ThemeVariant serializes via its
  # [TypeConverter(typeof(ThemeVariantTypeConverter))] - Light/Dark/Default
  # are `new(nameof(...))`, and ToString() returns that Key, so the JSON
  # keys are the literal strings "Light" and "Dark". Left empty: this repo
  # doesn't theme a light variant anywhere else (home/common/catppuccin.nix
  # is Mocha-only), so Light stays Avalonia's stock theme.
  themeJson = pkgs.writeText "libation-chardonnay-theme.json" (
    builtins.toJSON {
      ThemeColors = {
        Dark = fluentColors // libationColors;
        Light = { };
      };
    }
  );
in
{
  home.packages = [ pkgs.libation ];

  # Seeds Libation's own ChardonnayTheme.json with this repo's Catppuccin
  # Mocha palette, once. Libation owns this file after that - it rewrites
  # it whenever a color is changed in its own Settings UI - so an existing
  # file is left alone. Targets Libation's default library location; a
  # library moved elsewhere won't get seeded here.
  home.activation.seedLibationTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    themeFile="$HOME/.local/share/Libation/ChardonnayTheme.json"
    if [ ! -e "$themeFile" ]; then
      run mkdir -p "$(dirname "$themeFile")"
      run install -m644 ${themeJson} "$themeFile"
    fi
  '';
}
