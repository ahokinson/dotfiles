# This must stay the only import of inputs.catppuccin.homeModules.catppuccin.
# Its catppuccin.sources.* options are `unique`, so a second import is a hard
# "defined multiple times" error even when the two imports are identical.
#
# autoEnable stays a Linux-only decision in home/linux/catppuccin.nix; the
# darwin apps mostly ship their own hand-authored Mocha themes.
{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    # Both are hand-themed already (git/delta.nix, bat/default.nix), so the
    # module's ports would double up. ghostty is left to the module.
    delta.enable = false;
    bat.enable = false;
  };
}
