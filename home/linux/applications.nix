# Hides app-grid entries for CLI-only tools that still need to stay
# installed. home-manager writes to /etc/profiles/per-user, which precedes
# /run/current-system/sw in XDG_DATA_DIRS, so this shadows a same-named
# system copy for spec-compliant readers of that variable.
#
# COSMIC's app library isn't one: it doesn't prefer the earlier copy the way
# the ordering above says it should, so this only actually hides anything
# for a package with no system-level duplicate to lose to. cups and
# nixos-manual both had one; modules/nixos/printing.nix strips the former at
# the source instead, and modules/nixos/settings.nix drops the latter
# entirely, since nixpkgs synthesizes it inline with no package to swap.
_: {
  xdg.desktopEntries = {
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

    # programs.yazi (home/common/yazi.nix) installs it; pkgs.yazi ships a
    # yazi.desktop for launching from an app grid, which nothing here does.
    yazi = {
      name = "Yazi";
      exec = "yazi";
      noDisplay = true;
    };
  };
}
