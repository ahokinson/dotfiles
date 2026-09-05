{ selfPath, pkgs, ... }:
let
  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };
in
{
  home.packages = [ pkgs.hermes ];

  home.file = {
    ".hermes" = {
      source = selfPath "home/common/hermes/_files";
      recursive = true;
    };
  } // wireShared ".hermes" [ "SOUL.md" ];
}
