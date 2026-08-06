# Applies Zen browser settings/theme to whichever profile is actually the
# default on this machine, discovered at activation time by parsing
# profiles.ini — rather than declaring a profile path in nix (which is a
# random per-install salt, different on every machine, and can't be known
# in advance). This runs the same on every machine (macOS or Linux) and
# needs zero per-host configuration.
#
# Deliberately bypasses home-manager's own programs.zen-browser.profiles
# option: that option fully owns and regenerates profiles.ini from only the
# profiles it's told about, which orphaned a real profile once already when
# used to adopt an existing one. This only ever touches user.js and a
# chrome/ subdirectory inside the profile Zen already considers default —
# it never writes profiles.ini.
{ inputs, selfPath, config, lib, pkgs, ... }:
let
  prefs = import (selfPath "home/common/zen-browser-prefs.nix") { inherit pkgs selfPath; };

  toPrefLiteral = value:
    if builtins.isBool value then (if value then "true" else "false")
    else if builtins.isInt value || builtins.isFloat value then toString value
    else builtins.toJSON value;

  userJs = pkgs.writeText "zen-user.js" (
    lib.concatStringsSep "\n" (
      lib.sort builtins.lessThan (
        lib.mapAttrsToList (name: value: ''user_pref(${builtins.toJSON name}, ${toPrefLiteral value});'') prefs
      )
    )
    + "\n"
  );

  themeSources = builtins.fromJSON (builtins.readFile "${inputs.zen-browser}/sources.json");
  catppuccinZen = pkgs.fetchFromGitHub {
    inherit (themeSources.addons.catppuccin) rev hash;
    repo = "zen-browser";
    owner = "catppuccin";
  };
  theme = "${catppuccinZen}/themes/Frappe/Blue";

  userChromeCss = pkgs.writeText "zen-userChrome.css" ''@import "catppuccin/userChrome.css";'';
  userContentCss = pkgs.writeText "zen-userContent.css" ''@import "catppuccin/userContent.css";'';

  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "${config.home.homeDirectory}/Library/Application Support/zen"
    else "${config.home.homeDirectory}/.zen";

  # Zen can, on some launches, fail to recognize its own installation
  # identity and spawn a brand-new empty profile (self-labeled in that
  # profile's times.json as "source":"firstrun-created-default"), orphaning
  # the real one — installs.ini/profiles.ini end up with multiple per-install
  # Default= entries pointing at different profiles. Self-heals by finding
  # whichever entry's target profile is genuinely the oldest (times.json's
  # "created" field — a portable signal; file size is NOT reliable here,
  # since Firefox/Zen pre-allocates places.sqlite to a fixed size regardless
  # of actual content) and repointing every entry at it. No hardcoded path,
  # works on any machine, and only touches [InstallXXX]-style Default=
  # pointers, never the [ProfileN] Default=1 flag or the profile list itself.
  selfHealInstalls = pkgs.writeShellScript "zen-self-heal-installs" ''
    configDir="$1"
    installsIni="$configDir/installs.ini"
    profilesIni="$configDir/profiles.ini"
    [[ -f "$installsIni" ]] || exit 0

    bestPath=""
    bestCreated=""
    while IFS= read -r relPath; do
      [[ -z "$relPath" ]] && continue
      timesFile="$configDir/$relPath/times.json"
      [[ -f "$timesFile" ]] || continue
      created="$(${pkgs.jq}/bin/jq -r '.created // empty' "$timesFile" 2>/dev/null)"
      [[ "$created" =~ ^[0-9]+$ ]] || continue
      if [[ -z "$bestCreated" || "$created" -lt "$bestCreated" ]]; then
        bestCreated="$created"
        bestPath="$relPath"
      fi
    done < <(${pkgs.gawk}/bin/awk '/^Default=/ { sub(/^Default=/,""); print }' "$installsIni")

    [[ -z "$bestPath" ]] && exit 0

    ${pkgs.gawk}/bin/awk -v best="$bestPath" '
      /^Default=/ { print "Default=" best; next }
      { print }
    ' "$installsIni" > "$installsIni.zen-tmp" && mv "$installsIni.zen-tmp" "$installsIni"

    if [[ -f "$profilesIni" ]]; then
      ${pkgs.gawk}/bin/awk -v best="$bestPath" '
        /^\[Install/ { insec=1; print; next }
        /^\[/ { insec=0; print; next }
        insec && /^Default=/ { print "Default=" best; next }
        { print }
      ' "$profilesIni" > "$profilesIni.zen-tmp" && mv "$profilesIni.zen-tmp" "$profilesIni"
    fi
  '';

  # Prefers the per-install default-profile pointer ([InstallXXX] Default=)
  # over the legacy [ProfileN] Default=1 flag: on a machine with more than
  # one profile, the legacy flag can point at a stale/empty profile while
  # the per-install pointer is what the browser actually launches.
  findDefaultProfile = pkgs.writeShellScript "zen-find-default-profile" ''
    ${pkgs.gawk}/bin/awk '
      BEGIN { defaultpath=""; installpath=""; insec="" }
      /^\[Install/ { insec="install"; next }
      /^\[Profile/ { if (insec=="profile" && isdef && path!="") defaultpath=path; insec="profile"; path=""; isdef=0; next }
      /^\[/ { if (insec=="profile" && isdef && path!="") defaultpath=path; insec="" }
      insec=="install" && /^Default=/ { sub(/^Default=/,""); installpath=$0 }
      insec=="profile" && /^Path=/ { sub(/^Path=/,""); path=$0 }
      insec=="profile" && /^Default=1/ { isdef=1 }
      END {
        if (insec=="profile" && isdef && path!="") defaultpath=path;
        if (installpath!="") print installpath; else print defaultpath
      }
    ' "$1"
  '';
in {
  home.activation.zenSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    zenConfigDir=${lib.escapeShellArg configDir}
    run ${selfHealInstalls} "$zenConfigDir"
    zenIni="$zenConfigDir/profiles.ini"
    if [[ ! -f "$zenIni" ]]; then
      $VERBOSE_ECHO "zen-settings: no profiles.ini yet at $zenConfigDir, skipping"
    else
      zenRelPath="$(${findDefaultProfile} "$zenIni")"
      if [[ -z "$zenRelPath" ]]; then
        $VERBOSE_ECHO "zen-settings: could not determine the default profile from $zenIni, skipping"
      else
        zenProfileDir="$zenConfigDir/$zenRelPath"
        if [[ -d "$zenProfileDir" ]]; then
          run ${pkgs.coreutils}/bin/mkdir -p "$zenProfileDir/chrome"
          run ${pkgs.coreutils}/bin/cp -f "${userJs}" "$zenProfileDir/user.js"
          run ${pkgs.coreutils}/bin/cp -f "${userChromeCss}" "$zenProfileDir/chrome/userChrome.css"
          run ${pkgs.coreutils}/bin/cp -f "${userContentCss}" "$zenProfileDir/chrome/userContent.css"
          run ${pkgs.coreutils}/bin/ln -sfn "${theme}" "$zenProfileDir/chrome/catppuccin"
        else
          $VERBOSE_ECHO "zen-settings: resolved profile dir $zenProfileDir does not exist, skipping"
        fi
      fi
    fi
  '';
}
