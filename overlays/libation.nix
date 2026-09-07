# Libation isn't in nixpkgs. Upstream's own flake.nix is only a `nix
# develop` devShell for contributors (hardcoded x86_64-linux, no
# packages.default), so nothing to consume from it directly. This instead
# wraps upstream's prebuilt release binaries, which cover Linux amd64+arm64
# (.deb/.rpm) and macOS arm64+x64 (.dmg) - a from-source build would need a
# NuGet deps lock generated via a working Nix daemon, unavailable here.
#
# Version bumps: update `version` and the per-system `hash` below, both from
# https://github.com/rmcrackan/Libation/releases. The first build after a
# bump fails on a hash mismatch for whichever hash is now stale - paste the
# real one in from the error.
{ final, lib }:
let
  version = "14.1.0";
  system = final.stdenv.hostPlatform.system;

  sources = {
    x86_64-linux = {
      url = "https://github.com/rmcrackan/Libation/releases/download/v${version}/Libation.${version}-linux-chardonnay-amd64.deb";
      hash = lib.fakeHash;
    };
    aarch64-linux = {
      url = "https://github.com/rmcrackan/Libation/releases/download/v${version}/Libation.${version}-linux-chardonnay-arm64.deb";
      hash = "sha256-uQXxIha4dOc7IZ9U6QtiVz4JN6XclQRVrOoqPY9yDR4=";
    };
    aarch64-darwin = {
      url = "https://github.com/rmcrackan/Libation/releases/download/v${version}/Libation.${version}-macOS-chardonnay-arm64.dmg";
      hash = lib.fakeHash;
    };
  };

  source = sources.${system} or (throw "libation overlay: no release asset known for ${system}");

  src = final.fetchurl { inherit (source) url hash; };

  meta = with lib; {
    description = "Audiobook manager for Audible libraries";
    homepage = "https://github.com/rmcrackan/Libation";
    license = licenses.gpl3Only;
    mainProgram = "Libation";
  };

  # Avalonia's X11 backend, WebKitGTK for Avalonia.Controls.WebView, and
  # OpenSSL for System.Security.Cryptography.Native.OpenSsl are all resolved
  # by .NET's own managed DllImport loader rather than the ELF loader, so
  # they need LD_LIBRARY_PATH, not RPATH: confirmed by testing both ways
  # directly - autoPatchelfHook's runtimeDependencies (RPATH) left
  # libX11/libssl unresolved at runtime even with both visibly in the
  # RUNPATH; wrapping with LD_LIBRARY_PATH fixed both.
  linuxRuntimeLibs = with final; [
    (lib.getLib openssl)
    libx11
    libice
    libsm
    libxrandr
    libxi
    libxcursor
    libxext
    glib
    gtk3
    webkitgtk_4_1
  ];

  linux = final.stdenv.mkDerivation {
    pname = "libation";
    inherit version src;

    nativeBuildInputs = with final; [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    # From the .deb's actual ELF NEEDED entries (readelf -d on every bundled
    # .so): libstdc++/libgcc_s and libfontconfig. Everything else the
    # self-contained publish needs is bundled alongside the binaries
    # already.
    buildInputs = with final; [
      stdenv.cc.cc.lib
      fontconfig
    ];

    # libcoreclrtraceptprovider.so wants liblttng-ust.so.0 (.NET's optional
    # EventPipe tracing backend), an old SONAME nixpkgs' current lttng-ust
    # (2.15.1) doesn't provide. Not needed to run the app.
    autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    # Payload layout confirmed from the .deb itself: usr/lib/libation/{
    # Libation, Hangover, LibationCli} plus usr/share/{applications,icons}.
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib"
      cp -r usr/lib/libation "$out/lib/"

      mkdir -p "$out/bin"
      for exe in Libation Hangover LibationCli; do
        makeWrapper "$out/lib/libation/$exe" "$out/bin/$exe" \
          --prefix LD_LIBRARY_PATH : "${final.lib.makeLibraryPath linuxRuntimeLibs}" \
          --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
          --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
      done

      install -Dm444 usr/share/applications/Libation.desktop "$out/share/applications/Libation.desktop"
      install -Dm444 usr/share/icons/hicolor/scalable/apps/libation.svg \
        "$out/share/icons/hicolor/scalable/apps/libation.svg"
      substituteInPlace "$out/share/applications/Libation.desktop" \
        --replace-fail "Exec=env WEBKIT_DISABLE_COMPOSITING_MODE=1 libation" "Exec=$out/bin/Libation"

      runHook postInstall
    '';

    meta = meta // {
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };

  darwin = final.stdenv.mkDerivation {
    pname = "libation";
    inherit version src;

    nativeBuildInputs = [ final.undmg ];

    unpackPhase = "undmg $src";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -r Libation.app "$out/Applications/"
      # Ad-hoc sign so Gatekeeper accepts a locally-built copy.
      /usr/bin/codesign --force --deep --sign - "$out/Applications/Libation.app"
      runHook postInstall
    '';

    meta = meta // {
      platforms = [ "aarch64-darwin" ];
    };
  };
in
{
  libation = if final.stdenv.hostPlatform.isDarwin then darwin else linux;
}
