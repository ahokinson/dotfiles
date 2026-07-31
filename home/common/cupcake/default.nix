{ selfPath, config, pkgs, lib, ... }:
let
  destName = if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/cupcake"
    else ".config/cupcake";
in {
  home.packages = [ pkgs.cupcake ];

  # Only policies/{claude,opencode}/custom/ is version-controlled (see
  # _files/store/.gitignore) — everything else (the system/evaluate.rego
  # aggregator entrypoint, builtins/, rulebook.yml) is scaffolded locally by
  # `cupcake init --global` below, matching how cupcake expects to own that
  # generated config. Vendoring those generated files into the repo doesn't
  # work anyway: they're gitignored, so a flake build never sees them.
  home.file.${destName} = {
    source = selfPath "home/common/cupcake/_files/store";
    recursive = true;
  };

  # Idempotent: cupcake checks for its own rulebook.yml and no-ops with
  # "already initialized" if present, so this is safe to run on every
  # activation and never touches the custom/ policies deployed above.
  home.activation.cupcakeGlobalInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.cupcake}/bin/cupcake init --global --harness claude
    run ${pkgs.cupcake}/bin/cupcake init --global --harness opencode
  '';
}
