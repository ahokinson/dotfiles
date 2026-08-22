{ final, prev }: {
  # scorecard's non-Linux vendorHash is stale/wrong, breaking the
  # fixed-output goModules fetch. Patches the built FOD's outputHash
  # directly to the hash the build itself reports as correct; re-verify on
  # scorecard version bumps.
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
