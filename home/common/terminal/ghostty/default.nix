# The package is chosen per platform in package.nix; the Catppuccin theme
# comes from catppuccin/nix's ghostty module, not from this directory.
{
  imports = [
    ./package.nix
    ./settings.nix
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
}
