# reliquary is Nix-built and unsigned. On Apple Silicon its Keychain-ACL
# identity is tied to the binary's content hash, so every version bump (a
# new /nix/store path) invalidates every "Always Allow" grant and it
# re-prompts on every hook run. The build sandbox has no Keychain access, so
# signing can't happen in the derivation. Fix: copy the build out to
# ~/.local/bin (already first on $PATH) and sign that copy with a local
# self-signed cert, one-time per machine via Keychain Access. The identity
# then stays stable across upgrades.
{ pkgs, lib, ... }: {
  home.activation.signReliquary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.local/bin"
    run install -m755 "${pkgs.reliquary}/bin/reliquary" "$HOME/.local/bin/reliquary"
    /usr/bin/codesign --force --sign "reliquary-dev" \
      --identifier "dev.kingsfoil.reliquary" \
      "$HOME/.local/bin/reliquary"
  '';
}
