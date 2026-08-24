# Qt/Kvantum theming. Only ABI-safe when the whole Plasma/Qt stack is
# Nix-built (see catppuccin.nix) — not currently imported by any host, kept
# from the pre-COSMIC Plasma era in case a Qt-based desktop returns.
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
