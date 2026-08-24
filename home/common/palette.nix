# Shared hex palette for the Nix-side consumers that used to hardcode
# these colors independently: git/delta.nix, ghostty/theme.nix +
# settings.nix, zsh/init.nix's fzf colors, and (cross-referenced only in a
# comment, since it needs a hex->float conversion) home/linux/cosmic/theme.nix.
#
# Not wired into bat/btop/k9s/hermes/opencode's theme files: those are
# vendored ports of the same colors in foreign formats (tmTheme XML, a
# custom .theme format, YAML, JSON) maintained as static assets. Re-
# templating them from this attrset would be high-effort, easy to typo an
# obscure UI-role key, for no functional benefit - left untouched.
{
  rosewater = "#f2d5cf";
  flamingo = "#eebebe";
  pink = "#f4b8e4";
  mauve = "#ca9ee6";
  red = "#e78284";
  maroon = "#ea999c";
  peach = "#ef9f76";
  yellow = "#e5c890";
  green = "#a6d189";
  teal = "#81c8be";
  sky = "#99d1db";
  sapphire = "#85c1dc";
  blue = "#8caaee";
  lavender = "#babbf1";
  text = "#c6d0f5";
  subtext1 = "#b5bfe2";
  subtext0 = "#a5adce";
  overlay2 = "#949cbb";
  overlay1 = "#838ba7";
  overlay0 = "#737994";
  surface2 = "#626880";
  surface1 = "#51576d";
  surface0 = "#414559";
  base = "#303446";
  mantle = "#292c3c";
  crust = "#232634";
}
