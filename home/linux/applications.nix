# Hides entries for packages that must stay installed. home-manager writes to
# /etc/profiles/per-user, which precedes /run/current-system/sw in
# XDG_DATA_DIRS, so these shadow the system copies.
_: {
  xdg.desktopEntries = {
    # Ships inside pkgs.cups, so dropping it means dropping CUPS.
    cups = {
      name = "Manage Printing";
      exec = "xdg-open http://localhost:631/";
      noDisplay = true;
    };

    # From documentation.doc.enable, which also carries every package's
    # /share/doc.
    nixos-manual = {
      name = "NixOS Manual";
      exec = "nixos-help";
      noDisplay = true;
    };

    # Used from the terminal only; its .desktop entry is for launching from
    # an app grid, which nothing here does.
    btop = {
      name = "btop++";
      exec = "btop";
      noDisplay = true;
    };

    nvim = {
      name = "Neovim wrapper";
      exec = "nvim";
      noDisplay = true;
    };
  };
}
