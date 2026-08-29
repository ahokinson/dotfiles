# Linux-only home config. Imported by every NixOS host's home-manager
# section (framework13-amd-ryzen, bookpro14-m1-pro, studio-m1-max).
{ selfPath, ... }: {
  imports = [
    (selfPath "home/linux/catppuccin.nix")
    (selfPath "home/linux/icons")
    (selfPath "home/linux/packages.nix")
    (selfPath "home/linux/zen-browser.nix")
  ];
}
