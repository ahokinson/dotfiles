# ghostty config via the home-manager `programs.ghostty` module. Package
# selection is platform-specific (package.nix); the Catppuccin theme itself
# comes from catppuccin/nix's own ghostty module (home/common/catppuccin.nix
# enables it cross-platform), not from anything in this directory.
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
