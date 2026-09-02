# Dock and panel icons, generated: a simple-icons glyph recolored onto a
# rounded Frappe tile from palette.nix.
#
# simple-icons ships exactly one <path> per file against a 0 0 24 24 viewBox,
# which is what lets the extraction below be a string match rather than an XML
# parse. mkIcon throws if a file stops matching that shape.
{
  inputs,
  pkgs,
  selfPath,
}:
let
  palette = import (selfPath "home/common/palette.nix");

  # Fraction of the tile the glyph occupies; the rest is even padding.
  glyphScale = 0.56;
  inset = 24 * (1 - glyphScale) / 2;

  # 24 * 0.225, the corner radius proportion macOS uses on its app icons.
  cornerRadius = 5.4;

  # Not from palette.nix: Frappe has no white, and rosewater sinks into the
  # peach tile.
  glyphColor = "#ffffff";
in
{
  # name:     the desktop entry's Icon= key, which also becomes the filename.
  # glyph:    basename under glyphDir.
  # hue:      an attribute name in palette.nix.
  # glyphDir: defaults to simple-icons' icons/ directory; pass selfPath
  #           "home/common/_files" for a vendored glyph simple-icons doesn't
  #           carry (e.g. slack.svg — see home/linux/icons/default.nix).
  mkIcon =
    {
      name,
      glyph,
      hue,
      glyphDir ? "${inputs.simple-icons}/icons",
    }:
    let
      source = "${glyphDir}/${glyph}.svg";
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
