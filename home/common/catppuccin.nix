# Global Catppuccin Frappe toggle, shared by every platform. Split out of
# home/linux/catppuccin.nix (which stays Linux-only: GTK/icon-theme/cursor
# bits) so home/common/vesktop.nix can enable catppuccin.vesktop too -
# importing inputs.catppuccin.homeModules.catppuccin from two files in the
# same config is a hard error (its internal catppuccin.sources.* options are
# `unique`, so a second import trips a "defined multiple times" conflict even
# though both imports are identical), so this import has to be the only one.
#
# autoEnable is intentionally not set here: that stays a Linux-only decision
# in home/linux/catppuccin.nix. Turning it on globally would auto-theme every
# other catppuccin/nix-supported app this repo installs on darwin too, most
# of which already have their own hand-authored Frappe theme files.
{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "frappe";
    accent = "mauve";

    # delta and bat are hand-themed cross-platform already (git/delta.nix,
    # bat/default.nix); disable the module's ports of both so they aren't
    # double-themed. ghostty has no such override - catppuccin/nix's own
    # ghostty module is what themes it on every platform.
    delta.enable = false;
    bat.enable = false;
  };
}
