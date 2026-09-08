# Shared by modules/nixos/open-webui.nix and home/darwin/open-webui.nix.
# Open WebUI links a blank /static/custom.css it never ships, so this
# generates one: Tailwind's default gray scale remapped light->dark onto
# Mocha's neutral scale, plus the blue/green/red/yellow accents, `dark:`
# selectors only. Static mapping, not checked against the live app - patch
# whatever doesn't stick (code blocks and bare, non-`dark:` classes are the
# likely gaps).
{ pkgs, selfPath }:
let
  inherit (pkgs) lib;
  palette = import (selfPath "home/common/palette.nix");

  families = {
    gray = {
      "50" = palette.text;
      "100" = palette.subtext1;
      "200" = palette.subtext0;
      "300" = palette.overlay2;
      "400" = palette.overlay1;
      "500" = palette.overlay0;
      "600" = palette.surface2;
      "700" = palette.surface1;
      "800" = palette.surface0;
      "900" = palette.base;
      "950" = palette.mantle;
    };
    blue = {
      "500" = palette.blue;
      "600" = palette.blue;
    };
    green = {
      "500" = palette.green;
      "600" = palette.green;
    };
    red = {
      "500" = palette.red;
      "600" = palette.red;
    };
    yellow = {
      "500" = palette.yellow;
      "600" = palette.yellow;
    };
  };

  properties = {
    bg = "background-color";
    text = "color";
    border = "border-color";
  };

  rule =
    twPrefix: family: shade: color:
    ".dark .dark\\:${twPrefix}-${family}-${shade} { ${properties.${twPrefix}}: ${color} !important; }";

  rulesForFamily =
    family: shades:
    lib.concatMap (twPrefix: lib.mapAttrsToList (shade: color: rule twPrefix family shade color) shades)
      [
        "bg"
        "text"
        "border"
      ];

  allRules = lib.concatLists (lib.mapAttrsToList rulesForFamily families);
in
pkgs.writeText "open-webui-custom.css" ''
  /* Catppuccin Mocha for Open WebUI - generated from home/common/palette.nix.
     See home/common/open-webui-theme.nix for how and why. */
  ${lib.concatStringsSep "\n" allRules}

  .dark ::-webkit-scrollbar-thumb { background-color: ${palette.surface1} !important; }
  .dark ::-webkit-scrollbar-track { background-color: ${palette.mantle} !important; }
''
