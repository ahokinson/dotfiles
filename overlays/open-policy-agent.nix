{ prev }: {
  # nixpkgs' own test suite is broken (missing test fixture), unrelated to
  # the shipped binary.
  open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
}
