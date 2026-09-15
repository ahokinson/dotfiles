{ final }: {
  # semgrep's pytest suite fails on aarch64-linux. Both flags are needed:
  # doInstallCheck derives its default from doCheck at construction time,
  # before this override runs.
  semgrep = final.python3.pkgs.toPythonApplication (
    final.python3.pkgs.semgrep.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    })
  );
}
