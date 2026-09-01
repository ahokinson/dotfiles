{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.pharos ];

  # guards.ts is vendored from pharos's examples/; the package ships only the
  # binary. Its guard ids (risk/policy/judgement) must keep matching
  # cerberus's head names, which key the violations file it reads. If they
  # drift, every count silently renders zero.
  xdg.configFile."pharos" = {
    source = selfPath "home/common/pharos/_files";
    recursive = true;
  };
}
