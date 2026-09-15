{
  pkgs,
  lib,
  forWork,
  ...
}:
with pkgs;
lib.optionals (!forWork) [ twitch-cli ]
