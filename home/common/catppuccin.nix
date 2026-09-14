# This must stay the only import of inputs.catppuccin.homeModules.catppuccin.
# Its catppuccin.sources.* options are `unique`, so a second import is a hard
# "defined multiple times" error even when the two imports are identical.
#
# autoEnable is false on both platforms (home/darwin/catppuccin.nix,
# home/linux/catppuccin.nix), so every app themed through the module gets
# opted in explicitly rather than auto-ported - the ones below are the
# cross-platform apps with no theme of their own; each platform's own file
# lists the ones specific to it.
{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    # delta/bat are hand-themed already (git/delta.nix, bat/default.nix), so
    # the module's ports stay off for both - opting them in would double up.
    delta.enable = false;
    bat.enable = false;
    atuin.enable = true;
    eza.enable = true;
    ghostty.enable = true;
    mpv.enable = true;
    tmux.enable = true;
    yazi.enable = true;
  };
}
