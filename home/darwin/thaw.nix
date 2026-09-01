# Menu-bar item manager, a fork of Ice. Prebuilt only; nixpkgs cannot build
# it from source.
{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  loginItem = import (selfPath "home/darwin/login-item.nix") { inherit lib; };
in
{
  home.packages = [ pkgs.thaw ];

  home.activation.thawLoginItem = loginItem {
    name = "Thaw";
    appPath = "/Users/anders/Applications/Home Manager Apps/Thaw.app";
  };
}
