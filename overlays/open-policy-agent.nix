{ prev }: {
  # nixpkgs' test suite is missing a fixture.
  open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
}
