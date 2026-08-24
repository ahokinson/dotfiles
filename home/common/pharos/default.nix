{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.pharos ];

  # guards.ts is a vendored copy of pharos's own examples/guards.ts. The
  # package installs only the binary, so the plugin has to be deployed
  # separately. Its guard ids (risk/policy/judgement) have to keep matching
  # cerberus's head names, since that's what keys the violations file the
  # plugin reads; if they drift, every count silently renders zero.
  xdg.configFile."pharos" = {
    source = selfPath "home/common/pharos/_files";
    recursive = true;
  };
}
