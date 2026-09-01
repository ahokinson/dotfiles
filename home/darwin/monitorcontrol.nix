# External-display brightness and volume over DDC. Prebuilt only; nixpkgs
# cannot build it from source.
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
  home.packages = [ pkgs.monitorcontrol ];

  home.activation.monitorcontrolLoginItem = loginItem {
    name = "MonitorControl";
    appPath = "/Users/anders/Applications/Home Manager Apps/MonitorControl.app";
  };
}
