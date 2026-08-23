# KDE Plasma refuses to launch a .desktop file unless it's root-owned or
# executable — every Nix profile .desktop file fails both (store objects are
# read-only, mode 444). NixOS doesn't hit this; Asahi's foreign-distro Plasma
# did (confirmed on real hardware). Fix: copy (not symlink) each one into
# ~/.local/share/applications with the executable bit set, re-copying every
# activation to pick up package/config changes.
#
# Kept enabled now that Asahi is moving to COSMIC — harmless either way, but
# unverified whether COSMIC's own launcher/app-list is as strict about this
# as Plasma was. Re-check on real hardware; drop this file if it turns out
# not to be needed there.
{ lib, config, osConfig ? null, ... }:
lib.mkIf (osConfig == null) {
  home.activation.trustDesktopFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    appDir="${config.home.profileDirectory}/share/applications"
    destDir="$HOME/.local/share/applications"
    if [[ -d "$appDir" ]]; then
      run mkdir -p "$destDir"
      for f in "$appDir"/*.desktop; do
        [[ -e "$f" ]] || continue
        run install -m755 "$(readlink -f "$f")" "$destDir/$(basename "$f")"
      done
    fi
  '';
}
