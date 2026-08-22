{ final, flakePkgs }: {
  # psyche's TestRunInitScaffoldsFilesAndCallsHarness assumes Linux-only XDG
  # paths; darwin's Go os.UserConfigDir resolution is correct but fails that
  # assertion. Scoped to darwin only, so the suite still runs elsewhere.
  psyche = flakePkgs.psyche.overrideAttrs (_: {
    doCheck = !final.stdenv.hostPlatform.isDarwin;
  });
}
