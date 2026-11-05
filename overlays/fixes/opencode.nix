{ prev }: {
  # opencode 2.2.5's node_modules FOD outputHash is wrong on darwin, breaking
  # the bun install fetch. Patches the FOD's outputHash to what the build
  # itself reports. Re-verify on version bumps.
  opencode = prev.opencode.overrideAttrs (old: {
    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash = "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc=";
    });
  });
}
