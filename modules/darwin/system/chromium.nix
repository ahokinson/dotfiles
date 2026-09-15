# The managed-policy half of Chromium (mirrors modules/nixos/programs/chromium.nix's
# JSON). /Library/Managed Preferences is root-owned, so this stays a system
# activation script even though the app itself (home/darwin/apps/browsers/chromium.nix) is
# a plain home-manager package now.
{
  pkgs,
  selfPath,
  username,
  ...
}:
let
  policy = import (selfPath "home/common/apps/browsers/chromium/policy.nix");
  policyPlist = (pkgs.formats.plist { }).generate "org.chromium.Chromium.plist" policy;
  managedPrefsDir = "/Library/Managed Preferences/${username}";
in
{
  system.activationScripts.chromiumPolicy.text = ''
    install -d -m 0755 -o root -g wheel "${managedPrefsDir}"
    install -m 0644 -o root -g wheel "${policyPlist}" "${managedPrefsDir}/org.chromium.Chromium.plist"
  '';
}
