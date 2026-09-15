# reliquary is unsigned, and on Apple Silicon its Keychain-ACL identity is
# tied to the binary's content hash, so every version bump invalidates each
# "Always Allow" grant. The build sandbox has no Keychain access, so signing
# cannot happen in the derivation. Instead the build is copied to ~/.local/bin
# (already first on PATH) and signed there with a local self-signed cert,
# provisioned on first activation, which keeps the identity stable across
# upgrades. Never fatal: a failure here costs prompts, not the activation.
{ pkgs, lib, ... }:
let
  identity = "reliquary-dev";
  keychain = "$HOME/Library/Keychains/login.keychain-db";
in
{
  home.activation.signReliquary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! /usr/bin/security find-identity -p codesigning | grep -q "${identity}"; then
      noteEcho "reliquary: provisioning code-signing identity ${identity}"
      if ! (
        umask 077
        workdir=$(mktemp -d) || exit 1
        trap 'rm -f "$workdir/key.pem" "$workdir/cert.pem" "$workdir/id.p12"; rmdir "$workdir" 2>/dev/null' EXIT
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -sha256 \
          -days 3650 -nodes -subj "/CN=${identity}/C=US" \
          -addext "keyUsage=critical,digitalSignature" \
          -addext "extendedKeyUsage=critical,codeSigning" \
          -keyout "$workdir/key.pem" -out "$workdir/cert.pem" &&
        ${pkgs.openssl}/bin/openssl pkcs12 -export -passout pass: \
          -inkey "$workdir/key.pem" -in "$workdir/cert.pem" \
          -out "$workdir/id.p12" &&
        run /usr/bin/security import "$workdir/id.p12" \
          -k "${keychain}" -P "" -T /usr/bin/codesign
      ); then
        warnEcho "reliquary: could not create ${identity}; signing will be skipped"
      fi
    fi

    run mkdir -p "$HOME/.local/bin"
    run install -m755 "${pkgs.reliquary}/bin/reliquary" "$HOME/.local/bin/reliquary"

    if ! run /usr/bin/codesign --force --sign "${identity}" \
      --identifier "dev.kingsfoil.reliquary" \
      "$HOME/.local/bin/reliquary"; then
      warnEcho "reliquary: signing failed; Keychain will re-prompt until ${identity} is usable"
    fi
  '';
}
