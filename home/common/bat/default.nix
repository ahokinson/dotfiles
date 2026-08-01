# bat, themed with Catppuccin Frappe on every platform. Also provides the
# theme in bat's cache that delta reads for `syntax-theme = "Catppuccin Frappe"`.
#
# bat identifies a theme by the file's basename, so the file is named
# "Catppuccin Frappe.tmTheme" (no accent) even though the theme's internal name
# is "Catppuccin Frappé" - that basename is what `config.theme` and delta
# reference.
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
