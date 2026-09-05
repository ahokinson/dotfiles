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
  # Needs inputs.zen-browser.homeModules.beta in the importing host's own
  # home-manager config, since it comes from a flake input rather than
  # nixpkgs — every host adds it alongside home/common.
  imports = [ (selfPath "home/common/zen/extensions.nix") ];

  programs.zen-browser.enable = true;

  home.activation.zenSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Subshelled so the guard clauses below can exit early on the first unmet
    # precondition without exiting the rest of home-manager's activation
    # script, which this block is spliced into verbatim. run/warnEcho/
    # $VERBOSE_ECHO stay in scope: a subshell forks the same interpreter
    # rather than starting a new one.
    (
      zenConfigDir=""
      for zenCandidate in ${lib.escapeShellArgs activation.configDirs}; do
        if [[ -f "$zenCandidate/profiles.ini" ]]; then
          zenConfigDir="$zenCandidate"
          break
        fi
      done
      if [[ -z "$zenConfigDir" ]]; then
        # Loud, unlike the branches below: Zen moving its profile root out
        # from under us reverts the browser to stock, and silence hid that
        # once.
        warnEcho "zen: no profiles.ini in ${lib.concatStringsSep " or " activation.configDirs}, skipping"
        exit 0
      fi

      run ${activation.selfHealInstalls} "$zenConfigDir"
      zenRelPath="$(${activation.findDefaultProfile} "$zenConfigDir/profiles.ini")"
      if [[ -z "$zenRelPath" ]]; then
        $VERBOSE_ECHO "zen: could not determine the default profile from $zenConfigDir/profiles.ini, skipping"
        exit 0
      fi

      zenProfileDir="$zenConfigDir/$zenRelPath"
      if [[ ! -d "$zenProfileDir" ]]; then
        $VERBOSE_ECHO "zen: resolved profile dir $zenProfileDir does not exist, skipping"
        exit 0
      fi

      run ${pkgs.coreutils}/bin/mkdir -p "$zenProfileDir/chrome"
      run ${pkgs.coreutils}/bin/cp -f "${userJs}" "$zenProfileDir/user.js"
      run ${pkgs.coreutils}/bin/cp -f "${chrome.userChromeCss}" "$zenProfileDir/chrome/userChrome.css"
      run ${pkgs.coreutils}/bin/cp -f "${chrome.userContentCss}" "$zenProfileDir/chrome/userContent.css"
      run ${pkgs.coreutils}/bin/ln -sfn "${theme}" "$zenProfileDir/chrome/catppuccin"
    )
  '';
}
