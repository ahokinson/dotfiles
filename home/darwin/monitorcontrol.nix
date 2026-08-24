# MonitorControl: menu-bar utility for external-display brightness/volume via
# DDC. Prebuilt-only package (nixpkgs can't build it from source), darwin-only.
{ pkgs, lib, selfPath, ... }:
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
