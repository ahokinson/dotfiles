# Linux-only home packages. Imported by both NixOS and the Asahi standalone
# home-manager profile; use `lib.mkIf` to gate items that the standalone
# profile needs but NixOS provides directly via environment.systemPackages.
# `osConfig` is a specialArg home-manager injects only when it's wired in as
# a NixOS module, so `osConfig == null` cleanly identifies the standalone
# context (see home/linux/plasma/panel.nix for the same test in use).
{ pkgs, lib, osConfig ? null, ... }: {
  home.packages = with pkgs; lib.optionals (osConfig == null) [
    # ghostty installed via programs.ghostty (home/common/ghostty) instead.
    #
    # TODO: reconcile against what's actually dnf-installed beyond the base
    # Fedora KDE spin. On each Asahi machine, run:
    #   dnf repoquery --userinstalled --qf '%{name}\n' | sort
    # Anything with a nixpkgs equivalent moves into this list; anything
    # Asahi/kernel/firmware-specific that Nix can't provide gets a comment
    # here instead, so it's at least recorded.
  ];
}