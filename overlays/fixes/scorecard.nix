{ final, prev }: {
  # scorecard's non-Linux vendorHash is wrong, breaking the goModules fetch.
  # Patches the FOD's outputHash to what the build itself reports. Re-verify
  # on version bumps.
  scorecard =
    if final.stdenv.hostPlatform.isLinux then
      prev.scorecard
    else
      prev.scorecard.overrideAttrs (old: {
        goModules = old.goModules.overrideAttrs (_: {
          outputHash = "sha256-0KKKZheDNRPLBWtwXgXXG+ixpESO+Gq1FsW83PldiVo=";
        });
      });
}
