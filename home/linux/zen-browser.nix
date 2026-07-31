# Zen browser via the same home-manager module + beta channel used on
# darwin (see modules/darwin/home-manager.nix). Only wired into the Asahi
# flake output (flake.nix), not home/linux/default.nix's shared imports -
# NixOS gets plain nixpkgs `zen-browser` as a system package instead
# (modules/nixos/base.nix), since inputs.zen-browser.homeModules.beta isn't
# imported into its home-manager layer; importing this file there would
# hit an unknown-option eval error.
{ ... }: {
  programs.zen-browser.enable = true;
}
