{ pkgs, config }:
let
  # Which root a machine has depends on when Zen first ran there: it creates
  # new profiles under XDG but keeps using a legacy ~/.zen that predates that.
  # Probed in this order at activation time, so both stay supported.
  # Not programs.zen-browser.configPath, whose Darwin value is capital-Z Zen.
  configDirs =
    if pkgs.stdenv.hostPlatform.isDarwin then
      [ "${config.home.homeDirectory}/Library/Application Support/zen" ]
    else
      [
        "${config.home.homeDirectory}/.zen"
        "${config.xdg.configHome}/zen"
      ];

  # Zen sometimes spawns an empty profile and orphans the real one, leaving
  # multiple Default= entries. Repoints them all at the oldest times.json
  # "created". Not file size: Zen pre-allocates places.sqlite.
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

  # [InstallXXX] Default= wins over the legacy [ProfileN] Default=1, which
  # can point at a stale profile when there is more than one.
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
in
{
  inherit configDirs selfHealInstalls findDefaultProfile;
}
