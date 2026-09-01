# The default profile name is a random per-install salt, so it is resolved
# from profiles.ini at activation time. Bypasses
# programs.zen-browser.profiles, which owns and regenerates profiles.ini and
# orphaned a real profile once while adopting it. Only user.js and chrome/
# are touched.
{
  inputs,
  selfPath,
  config,
  lib,
  pkgs,
  ...
}:
let
  activation = import (selfPath "home/common/zen/activation.nix") { inherit pkgs config; };
  userJs = import (selfPath "home/common/zen/prefs.nix") { inherit pkgs lib selfPath; };
  theme = import (selfPath "home/common/zen/theme.nix") { inherit inputs pkgs; };
  chrome = import (selfPath "home/common/zen/chrome.nix") { inherit pkgs; };
in
{
  home.activation.zenSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    zenConfigDir=${lib.escapeShellArg activation.configDir}
    run ${activation.selfHealInstalls} "$zenConfigDir"
    zenIni="$zenConfigDir/profiles.ini"
    if [[ ! -f "$zenIni" ]]; then
      $VERBOSE_ECHO "zen: no profiles.ini yet at $zenConfigDir, skipping"
    else
      zenRelPath="$(${activation.findDefaultProfile} "$zenIni")"
      if [[ -z "$zenRelPath" ]]; then
        $VERBOSE_ECHO "zen: could not determine the default profile from $zenIni, skipping"
      else
        zenProfileDir="$zenConfigDir/$zenRelPath"
        if [[ -d "$zenProfileDir" ]]; then
          run ${pkgs.coreutils}/bin/mkdir -p "$zenProfileDir/chrome"
          run ${pkgs.coreutils}/bin/cp -f "${userJs}" "$zenProfileDir/user.js"
          run ${pkgs.coreutils}/bin/cp -f "${chrome.userChromeCss}" "$zenProfileDir/chrome/userChrome.css"
          run ${pkgs.coreutils}/bin/cp -f "${chrome.userContentCss}" "$zenProfileDir/chrome/userContent.css"
          run ${pkgs.coreutils}/bin/ln -sfn "${theme}" "$zenProfileDir/chrome/catppuccin"
        else
          $VERBOSE_ECHO "zen: resolved profile dir $zenProfileDir does not exist, skipping"
        fi
      fi
    fi
  '';
}
