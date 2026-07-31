# Qt/Kvantum theming - NixOS only, not imported by the Asahi flake output.
# Only safe when the whole Plasma/Qt stack is Nix-built (true on NixOS,
# where services.desktopManager.plasma6 provides it); on a foreign distro
# like Asahi Fedora, Plasma is the distro's own RPM-installed build using
# its own system Qt, and pointing it at these Nix-built plugins via env
# vars is an ABI mismatch that crashes every Qt/Plasma process on load.
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
