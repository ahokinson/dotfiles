# Catppuccin-flavored icons for the pinned dock/panel apps, generated rather
# than vendored: each app's glyph comes from simple-icons and is recolored
# onto a rounded Frappe tile. The colors are read from palette.nix, the same
# source ghostty/delta/fzf use, so retuning the palette moves the icons with
# it and nothing binary lands in the repo.
#
# Only the glyph outline is taken from upstream. simple-icons ships exactly
# one <path> per file against a 0 0 24 24 viewBox, which is what lets the
# extraction below be a string match instead of an XML parse. mkIcon throws
# rather than emitting a blank tile if a file ever stops matching that shape.
{
  inputs,
  pkgs,
  selfPath,
}:
let
  palette = import (selfPath "home/common/palette.nix");

  # Fraction of the tile the glyph occupies; the remainder is split evenly as
  # padding, keeping the mark clear of the rounded corners.
  glyphScale = 0.56;
  inset = 24 * (1 - glyphScale) / 2;

  # 24 * 0.225, the corner radius proportion macOS uses on its own app icons -
  # the look WhiteSur is here to imitate everywhere else.
  cornerRadius = 5.4;

  # The tile carries the app's hue and the mark sits on it in white, so the
  # icon keeps a visible body against COSMIC's dark panel. Deliberately not
  # from palette.nix: Frappe has no white, and its lightest color (rosewater)
  # is both barely lighter than text and warm enough to sink into the peach
  # tile.
  glyphColor = "#ffffff";
in
{
  # name:  the desktop entry's Icon= key, which also becomes the filename.
  # glyph: basename under simple-icons' icons/ directory.
  # hue:   an attribute name in palette.nix.
  mkIcon =
    {
      name,
      glyph,
      hue,
    }:
    let
      source = "${inputs.simple-icons}/icons/${glyph}.svg";
      matched = builtins.match ''.*<path d="([^"]+)".*'' (builtins.readFile source);
      pathData =
        if matched == null then
          throw "icons.nix: no single-path glyph found in ${source}; simple-icons changed shape"
        else
          builtins.head matched;
    in
    pkgs.writeText "${name}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
        <rect width="24" height="24" rx="${toString cornerRadius}" fill="${palette.${hue}}"/>
        <g transform="translate(${toString inset} ${toString inset}) scale(${toString glyphScale})">
          <path d="${pathData}" fill="${glyphColor}"/>
        </g>
      </svg>
    '';
}
