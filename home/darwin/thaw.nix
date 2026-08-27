# Thaw: menu-bar item hider/manager for macOS, fork of Ice. Prebuilt-only
# package (nixpkgs can't build it from source), darwin-only.
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
