# Menu-bar item manager, a fork of Ice. Prebuilt only; nixpkgs cannot build
# it from source.
{
  pkgs,
  lib,
  config,
  selfPath,
  ...
}:
let
  loginItem = import (selfPath "home/darwin/login-item.nix") { inherit lib config; };
in
{
  home.packages = [ pkgs.thaw ];

  home.activation.thawLoginItem = loginItem { name = "Thaw"; };
}
