# KDE Plasma refuses to launch a .desktop file unless it's owned by root or
# has the executable bit set (a check against untrusted Type=Application
# entries) - confirmed on real Asahi hardware: "Access to
# /nix/store/.../zen-beta.desktop denied. not owned by root and executable
# flag not set." Every .desktop file a Nix profile installs fails both
# conditions on a foreign distro like Asahi (Nix store objects are read-only
# data files, mode 444, and not root-owned outside a multi-user daemon
# install) - not a stale-build problem, so re-running `home-manager switch`
# alone doesn't fix it. NixOS doesn't hit this (see
# discourse.nixos.org/t/kde-desktop-files-on-ubuntu/7724 - "this problem
# doesn't exist on a pure NixOS... KDE Plasma"), so this is Asahi-only.
#
# Fix: copy (not symlink - the store is immutable, chmod on it fails
# outright) every profile .desktop file into ~/.local/share/applications
# with the executable bit set, so KDE's check passes on the copy while Nix
# keeps owning the original. Re-copies on every activation to pick up
# package/config changes; doesn't prune copies for since-removed packages.
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
