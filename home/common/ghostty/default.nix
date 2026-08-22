# ghostty config via the home-manager `programs.ghostty` module. Package
# selection is platform-specific (package.nix); palette ownership is split
# by platform (theme.nix here, home/linux/catppuccin.nix on Linux).
{
  imports = [
    ./package.nix
    ./settings.nix
    ./theme.nix
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
}
