# reliquary is built by Nix (pkgs/reliquary.nix in inputs.flake), and Nix
# never code-signs the result. On Apple Silicon, an unsigned binary's
# Keychain-ACL identity is tied to its content hash, so every version bump
# produces a new /nix/store path -> a "new app" to Keychain -> every
# previously-granted "Always Allow" on each secret's keychain item is
# invalidated, and reliquary starts re-prompting on every hook run again.
# The store is immutable and its build sandbox has no Keychain access, so
# signing can't happen in the derivation (same constraint as
# home/linux/desktop-file-trust.nix). Fix: copy the built binary out to
# ~/.local/bin (already first on $PATH, see home/common/zsh/default.nix)
# and sign that copy with a local self-signed cert (Keychain Access ->
# Certificate Assistant -> Create a Certificate -> Self Signed Root / Code
# Signing -> name it "reliquary-dev", one-time per machine). As long as the
# same cert keeps signing it, the code identity stays stable across future
# `reliquary` version bumps, so Keychain's "Always Allow" persists instead
# of re-prompting on every upgrade.
{ pkgs, lib, ... }: {
  home.activation.signReliquary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.local/bin"
    run install -m755 "${pkgs.reliquary}/bin/reliquary" "$HOME/.local/bin/reliquary"
    /usr/bin/codesign --force --sign "reliquary-dev" \
      --identifier "dev.kingsfoil.reliquary" \
      "$HOME/.local/bin/reliquary"
  '';
}
