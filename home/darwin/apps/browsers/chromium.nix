# No nixpkgs Darwin build of Chromium exists, and Homebrew's own chromium
# cask has been disabled since 2026-09-01 for failing Gatekeeper (unsigned
# regardless of distribution channel), so this fetches Google's own unsigned
# continuous-build snapshot (arm64 - all three Mac hosts are Apple Silicon)
# directly. $out/Applications/Chromium.app is the shape home-manager's own
# home.packages scanning expects (pathsToLink "/Applications"), so listing it
# there is all that's needed - no activation script, no manual copy.
#
# Unsigned build: first launch needs one manual right-click -> Open per
# machine to clear Gatekeeper's quarantine flag, the accepted cost of not
# depending on Homebrew here.
#
# To bump the pinned build: check
# https://storage.googleapis.com/chromium-browser-snapshots/Mac_Arm/LAST_CHANGE
# for the current build number, update chromiumBuild, then build with hash
# set back to lib.fakeHash - it fails with the real hash to paste in.
{ pkgs, ... }:
let
  chromiumBuild = "1696981";
  chromiumZip = pkgs.fetchurl {
    url = "https://storage.googleapis.com/chromium-browser-snapshots/Mac_Arm/${chromiumBuild}/chrome-mac.zip";
    hash = "sha256-b9wqnbHQRzGSNsdPFaXusHno9wT/3GusWIKxX9yQKd4=";
  };
  chromiumApp = pkgs.runCommand "chromium-app" { nativeBuildInputs = [ pkgs.unzip ]; } ''
    unzip -q ${chromiumZip}
    mkdir -p $out/Applications
    mv chrome-mac/Chromium.app $out/Applications/Chromium.app
  '';
in
{
  home.packages = [ chromiumApp ];
}
