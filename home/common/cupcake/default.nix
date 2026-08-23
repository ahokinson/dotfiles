{ inputs, pkgs, lib, ... }:
let
  destName = if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/cupcake"
    else ".config/cupcake";

  # Custom policies now live at github:ahokinson/cupcake (flake.nix's
  # cupcake input, fetched as a plain source tree).
  customPolicies = "${inputs.cupcake}/custom";
in {
  home.packages = [ pkgs.cupcake ];

  # One source, deployed to both harnesses. cupcakeGlobalInit below still
  # writes system/evaluate.rego, builtins/, and rulebook.yml as siblings of
  # this symlink inside each policies/<harness>/ dir.
  home.file."${destName}/policies/claude/custom".source = customPolicies;
  home.file."${destName}/policies/opencode/custom".source = customPolicies;

  # Idempotent: cupcake checks for its own rulebook.yml and no-ops with
  # "already initialized" if present, so this is safe to run on every
  # activation and never touches the custom/ policies deployed above.
  home.activation.cupcakeGlobalInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.cupcake}/bin/cupcake init --global --harness claude
    run ${pkgs.cupcake}/bin/cupcake init --global --harness opencode
  '';

  # Cupcake needs a *project-level* .cupcake/ in whatever cwd `cupcake eval`
  # runs from (cerberus's policy head and opencode's cupcake-guard.js both
  # run it from here), while the global store above only supplies the rules
  # that apply on top of that. `cerberus init` creates this same stub, so
  # this stays the declarative path to it. Idempotent, like cupcakeGlobalInit
  # above.
  home.activation.cupcakeStubInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cupcakeStub="''${XDG_DATA_HOME:-$HOME/.local/share}/cupcake-stub"
    if [[ ! -d "$cupcakeStub/.cupcake/policies/claude" ]]; then
      run ${pkgs.coreutils}/bin/mkdir -p "$cupcakeStub"
      ( cd "$cupcakeStub" && run ${pkgs.cupcake}/bin/cupcake init --harness claude )
    fi
    if [[ ! -d "$cupcakeStub/.cupcake/policies/opencode" ]]; then
      ( cd "$cupcakeStub" && run ${pkgs.cupcake}/bin/cupcake init --harness opencode )
    fi
  '';
}
