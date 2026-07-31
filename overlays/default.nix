# claude-code, codex, and opencode are plain nixpkgs packages - used directly
# as pkgs.claude-code / pkgs.codex / pkgs.opencode, not listed here.
inputs: final: prev:
inputs.flake.overlays.default final prev // {
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
