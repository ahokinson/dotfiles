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
  # shipped binary, which works fine.
  semgrep = prev.semgrep.overrideAttrs (_: {
    doCheck = false;
  });
}
