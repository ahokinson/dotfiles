# Linux-only home config, imported by every NixOS host.
{ selfPath, ... }: {
  imports = [
    (selfPath "home/linux/applications.nix")
    (selfPath "home/linux/catppuccin.nix")
    (selfPath "home/linux/icons")
    (selfPath "home/linux/obs.nix")
    (selfPath "home/linux/packages.nix")
    (selfPath "home/linux/zathura.nix")
  ];
}
