{ pkgs, ... }:
with pkgs;
[
  # Reads per-connection data off raw sockets, so it needs root: run it via
  # sudo. Nothing else in this repo gets a wrapper/capability treatment.
  bandwhich
  httpie
  inetutils
  nmap
  proton-vpn
  rsync
]
