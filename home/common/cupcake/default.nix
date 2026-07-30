{ pkgs, lib, ... }:
let
  destName = if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/cupcake"
    else ".config/cupcake";
in {
  home.packages = [ pkgs.cupcake ];

  home.file.${destName} = {
    source = ./_files/store;
    recursive = true;
  };
}
