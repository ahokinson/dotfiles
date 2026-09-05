# The live checkout's path, not a store path: claude/default.nix's
# mkOutOfStoreSymlink needs a mutable path for Claude Code's runtime writes
# to settings.json to survive, and nh.nix's flake option must resolve to the
# live checkout at runtime rather than being copied into the store. Assumes
# the checkout is at ~/.dotfiles.
{ config }: "${config.home.homeDirectory}/.dotfiles"
