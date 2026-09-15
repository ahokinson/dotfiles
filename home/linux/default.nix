# Linux-only home config, imported by every NixOS host.
{ selfPath, ... }: {
  imports = [
    (selfPath "home/linux/apps/obs.nix")
    (selfPath "home/linux/apps/zathura.nix")
    (selfPath "home/linux/desktop/icons")
    (selfPath "home/linux/desktop/integration/applications.nix")
    (selfPath "home/linux/desktop/theme/catppuccin.nix")
    (selfPath "home/linux/packages")
  ];
}
