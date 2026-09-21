# Shared between NixOS and Darwin: imported by modules/nixos/core/user.nix
# and modules/darwin/system/account.nix, whose own account definitions
# otherwise diverge too much to share.
_: {
  programs.zsh.enable = true;
}
