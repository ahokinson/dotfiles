# claude-code, codex, and opencode are plain nixpkgs packages - used directly
# as pkgs.claude-code / pkgs.codex / pkgs.opencode, not listed here.
inputs: final: prev:
let
  # ahokinson/flake's own package set. Bound so packages it provides (psyche
  # below) can be overridden here - they are not in `prev`, which is plain
  # nixpkgs.
  flakePkgs = inputs.flake.overlays.default final prev;
in
flakePkgs // {
  # psyche's TestRunInitScaffoldsFilesAndCallsHarness (init_test.go:73) asserts
  # XDG paths - `.config/psyche/config.json` - but on darwin the binary
  # correctly resolves Go's os.UserConfigDir to `~/Library/Application
  # Support/psyche/`, so the assertion fails against output that is right. The
  # test's assumption is Linux-only, not the binary's behavior: a doCheck=false
  # build renders `psyche --format claude SOUL.md` to well-formed SessionStart
  # hook JSON. Scoped to darwin so the suite still runs on NixOS and Asahi,
  # where the XDG assumption holds. Drop this once the test is platform-aware
  # upstream.
  psyche = flakePkgs.psyche.overrideAttrs (_: {
    doCheck = !final.stdenv.hostPlatform.isDarwin;
  });

  # nixpkgs' own test suite is broken (missing test fixture in
  # v1/server/compile_handler_test.go, unrelated to the shipped binary).
  open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });

  # semgrep's pytest suite fails on aarch64-linux (75 failures, all
  # "Failed to obtain target files from semgrep-core") - unrelated to the
  # shipped binary, which works fine. pkgs.semgrep is just
  # `toPythonApplication python3.pkgs.semgrep` - the failing tests belong
  # to the underlying python3.pkgs.semgrep derivation, not the application
  # wrapper, so that's what has to be overridden. Both doCheck (gates
  # checkPhase) AND doInstallCheck (gates installCheckPhase, where this
  # particular suite actually runs - buildPythonPackage derives its
  # default from doCheck's *original* value at construction time, before
  # this override runs, so it doesn't follow doCheck automatically) have
  # to be disabled.
  semgrep = final.python3.pkgs.toPythonApplication (
    final.python3.pkgs.semgrep.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    })
  );
}
