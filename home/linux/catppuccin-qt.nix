# Qt/Kvantum theming - NixOS only, not imported by the Asahi flake output.
# Only ABI-safe when the whole Plasma/Qt stack is Nix-built (true on NixOS);
# on Asahi's Fedora-built Plasma this crashes every Qt process on load (see
# catppuccin.nix).
{ ... }:
{
  # Qt plumbing: Plasma provides the platform theme; Kvantum provides the
  # actual style. The catppuccin kvantum module (see catppuccin.nix)
  # asserts that `qt.style.name == "kvantum"`.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };
}
