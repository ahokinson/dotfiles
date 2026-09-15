# Darwin's half of the enable/autoEnable split (home/linux/desktop/theme/catppuccin.nix is
# the other). Nothing darwin-only needs to opt in here: the cross-platform
# apps that need it (including ghostty) are listed in
# home/common/theme/catppuccin.nix, and everything else darwin-specific either
# hand-authors its own Mocha theme or has no catppuccin/nix port at all.
_: {
  catppuccin.autoEnable = false;
}
