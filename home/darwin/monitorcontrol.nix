# External-display brightness and volume over DDC. Prebuilt only; nixpkgs
# cannot build it from source.
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
  home.packages = [ pkgs.monitorcontrol ];

  home.activation.monitorcontrolLoginItem = loginItem { name = "MonitorControl"; };
}
