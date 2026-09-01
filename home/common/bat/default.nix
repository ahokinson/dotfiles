# Also builds the cached theme delta reads as `syntax-theme`.
#
# bat identifies a theme by the file's basename, so the file is "Catppuccin
# Frappe.tmTheme" with no accent, even though the theme's internal name has
# one. That basename is what config.theme and delta reference.
{ selfPath, ... }: {
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
    themes."Catppuccin Frappe" = {
      src = selfPath "home/common/bat/themes";
      file = "Catppuccin Frappe.tmTheme";
    };
  };
}
