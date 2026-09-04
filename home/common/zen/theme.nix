{ inputs, pkgs }:
let
  themeSources = builtins.fromJSON (builtins.readFile "${inputs.zen-browser}/sources.json");
  catppuccinZen = pkgs.fetchFromGitHub {
    inherit (themeSources.addons.catppuccin) rev hash;
    repo = "zen-browser";
    owner = "catppuccin";
  };
in
"${catppuccinZen}/themes/Mocha/Blue"
