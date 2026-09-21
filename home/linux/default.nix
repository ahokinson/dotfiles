# Linux-only home config, imported by every NixOS host.
{ selfPath, ... }: {
  imports = [
    (selfPath "home/linux/apps/desktop/brlcad.nix")
    (selfPath "home/linux/apps/desktop/obs.nix")
    (selfPath "home/linux/apps/desktop/orca-slicer.nix")
    (selfPath "home/linux/apps/desktop/zathura.nix")
    (selfPath "home/linux/apps/messaging/slack.nix")
    (selfPath "home/linux/desktop/icons")
    (selfPath "home/linux/desktop/integration/applications.nix")
    (selfPath "home/linux/desktop/theme/catppuccin.nix")
  ];
}
