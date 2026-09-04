# Also builds the cached theme delta reads as `syntax-theme`.
#
# bat identifies a theme by the file's basename, so that is what config.theme
# and delta reference, not the name inside the file.
{ selfPath, ... }: {
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Mocha";
    themes."Catppuccin Mocha" = {
      src = selfPath "home/common/bat/themes";
      file = "Catppuccin Mocha.tmTheme";
    };
  };
}
