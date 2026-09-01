# Needs inputs.zen-browser.homeModules.beta in the importing config, added
# per-host since it comes from a flake input. Every consumer does so.
{ selfPath, ... }: {
  imports = [ (selfPath "home/common/zen/extensions.nix") ];

  programs.zen-browser.enable = true;
}
