# Applies Zen settings/theme to whichever profile is the machine's actual
# default, found at activation time via profiles.ini (never known in advance
# — it's a random per-install salt). Deliberately bypasses home-manager's own
# programs.zen-browser.profiles option: that option fully owns and
# regenerates profiles.ini, which orphaned a real profile once already when
# used to adopt an existing one. This only ever touches user.js and a
# chrome/ subdirectory in the profile Zen already considers default.
{ inputs, selfPath, config, lib, pkgs, ... }:
let
  activation = import (selfPath "home/common/zen/activation.nix") { inherit pkgs config; };
  userJs = import (selfPath "home/common/zen/prefs.nix") { inherit pkgs lib selfPath; };
  theme = import (selfPath "home/common/zen/theme.nix") { inherit inputs pkgs; };
  chrome = import (selfPath "home/common/zen/chrome.nix") { inherit pkgs lib; };
in {
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
