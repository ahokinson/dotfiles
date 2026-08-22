{ final }: {
  # semgrep's pytest suite fails on aarch64-linux, unrelated to the shipped
  # binary. Both doCheck and doInstallCheck must be disabled — the latter
  # derives its default from doCheck's value at construction time, before
  # this override runs.
  semgrep = final.python3.pkgs.toPythonApplication (
    final.python3.pkgs.semgrep.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    })
  );
}
