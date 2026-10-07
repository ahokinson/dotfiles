# A module here, not a catalog entry, because mitos exists to drive the
# harnesses around it (claude, codex, opencode) - it belongs with them.
# No configuration of its own: upstream ships no required setup.
{ pkgs, ... }:
{
  home.packages = [ pkgs.mitos ];
}
