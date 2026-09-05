# Also builds the cached theme delta reads as `syntax-theme`.
#
# bat identifies a theme by the file's basename, so that is what config.theme
# and delta reference, not the name inside the file.
{ selfPath, ... }:
let
  themeName = import (selfPath "home/common/bat/theme-name.nix");
in
{
  programs.bat = {
    enable = true;
    config.theme = themeName;
    themes.${themeName} = {
      src = selfPath "home/common/bat/themes";
      file = "Catppuccin Mocha.tmTheme";
    };
  };
}
