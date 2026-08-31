# Desktop entries for packages that have to stay installed but don't belong in
# the app library. home-manager's entries land in /etc/profiles/per-user, which
# precedes /run/current-system/sw in XDG_DATA_DIRS, so these shadow the
# system copies.
_: {
  xdg.desktopEntries = {
    # Ships inside pkgs.cups, so dropping it means dropping CUPS.
    cups = {
      name = "Manage Printing";
      exec = "xdg-open http://localhost:631/";
      noDisplay = true;
    };

    # Comes from documentation.doc.enable, which also carries /share/doc for
    # every package.
    nixos-manual = {
      name = "NixOS Manual";
      exec = "nixos-help";
      noDisplay = true;
    };
  };
}
