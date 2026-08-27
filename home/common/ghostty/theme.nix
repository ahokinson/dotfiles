# On Linux the catppuccin home-manager module (home/linux/catppuccin.nix)
# installs this theme and sets programs.ghostty.settings.theme itself;
# declaring it here too would conflict on xdg.configFile. macOS doesn't
# import that module, so the palette is declared inline here instead.
{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  palette = import (selfPath "home/common/palette.nix");
  hex = lib.removePrefix "#";
in
{
  programs.ghostty.themes = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    catppuccin-frappe = {
      palette = [
        "0=${palette.surface1}"
        "1=${palette.red}"
        "2=${palette.green}"
        "3=${palette.yellow}"
        "4=${palette.blue}"
        "5=${palette.pink}"
        "6=${palette.teal}"
        "7=${palette.subtext0}"
        "8=${palette.surface2}"
        "9=${palette.red}"
        "10=${palette.green}"
        "11=${palette.yellow}"
        "12=${palette.blue}"
        "13=${palette.pink}"
        "14=${palette.teal}"
        "15=${palette.subtext1}"
      ];
      background = hex palette.base;
      foreground = hex palette.text;
      cursor-color = hex palette.rosewater;
      cursor-text = hex palette.crust;
      # Custom blend, not part of the standard 26-color palette.
      selection-background = "44495d";
      selection-foreground = hex palette.text;
    };
  };
}
