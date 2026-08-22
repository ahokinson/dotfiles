# Zen browser via the same home-manager module + beta channel used on
# darwin (see modules/darwin/home-manager.nix). Requires
# inputs.zen-browser.homeModules.beta in the importing config's module
# list (added per-host, since it comes from a flake input) - every
# home/linux/default.nix consumer (NixOS hosts, the Asahi profile) does so.
{ selfPath, ... }: {
  imports = [ (selfPath "home/common/zen/extensions.nix") ];

  programs.zen-browser.enable = true;
}
