# darwin uses the signed macOS binary directly — nixpkgs' pkgs.ghostty has
# no darwin platform support (upstream lacks a Swift 6/xcodebuild-friendly
# nixpkgs environment). Asahi's Nix-built Linux binary fails to acquire a
# GL context against Fedora's own Mesa/libwayland ("unable to acquire an
# opengl context for rendering"), so it launches through a wrapper that
# symlinks Fedora's own GL/wayland libraries into LD_LIBRARY_PATH instead
# of resolving them from the Nix store.
{ pkgs, osConfig ? null, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # osConfig is a specialArg home-manager injects only when wired in as a
  # NixOS module - absent (default null) for the standalone Asahi profile,
  # same test used in home/linux/cosmic/panel.nix and friends.
  isAsahi = !isDarwin && osConfig == null;

  ghosttyAsahiGl = pkgs.symlinkJoin {
    name = "ghostty-asahi-gl";
    paths = [ pkgs.ghostty ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ghostty --run '
        libdir="$HOME/.cache/ghostty-asahi-gl-libs"
        mkdir -p "$libdir"
        for pattern in "libwayland-*.so*" "libEGL*.so*" "libGL*.so*" "libOpenGL*.so*" "libgbm.so*" "libdrm*.so*"; do
          for f in /usr/lib64/$pattern /usr/lib/$pattern; do
            [ -e "$f" ] && ln -sf "$f" "$libdir/$(basename "$f")"
          done
        done
        export LD_LIBRARY_PATH="$libdir:$LD_LIBRARY_PATH"
        export LIBGL_DRIVERS_PATH=/usr/lib64/dri
        export __EGL_VENDOR_LIBRARY_DIRS=/usr/share/glvnd/egl_vendor.d
      '

      # The .desktop/.service files symlinkJoin carries through bake an
      # absolute Exec=/ExecStart= path to ghostty's own unwrapped store
      # path, bypassing this wrapper entirely — regenerate both pointing at
      # $out/bin/ghostty instead.
      rm -f $out/share/applications/com.mitchellh.ghostty.desktop
      sed "s|${pkgs.ghostty}/bin/ghostty|$out/bin/ghostty|g" \
        ${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop \
        > $out/share/applications/com.mitchellh.ghostty.desktop

      rm -f $out/share/systemd/user/app-com.mitchellh.ghostty.service
      sed "s|${pkgs.ghostty}/bin/ghostty|$out/bin/ghostty|g" \
        ${pkgs.ghostty}/share/systemd/user/app-com.mitchellh.ghostty.service \
        > $out/share/systemd/user/app-com.mitchellh.ghostty.service
    '';
    # symlinkJoin doesn't carry the wrapped package's meta over, and
    # lib.getExe would otherwise guess "ghostty-asahi-gl" from this
    # derivation's own name - which doesn't exist in $out/bin, only
    # "ghostty" does.
    meta = pkgs.ghostty.meta // { mainProgram = "ghostty"; };
  };
in {
  programs.ghostty.package =
    if isDarwin then pkgs.ghostty-bin
    else if isAsahi then ghosttyAsahiGl
    else pkgs.ghostty;
}
