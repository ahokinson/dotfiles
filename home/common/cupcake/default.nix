{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.cupcake ];

  # cerberus is the only caller of `cupcake eval` now that the opencode JS
  # guards are gone, and it always passes --harness claude, so a
  # policies/opencode/ store would never be read. Policies themselves come
  # from home/common/cerberus, not from here.
  home.activation.cupcakeGlobalInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.cupcake}/bin/cupcake init --global --harness claude
  '';

  # `cupcake eval` needs a project-level .cupcake/ in its cwd; the global
  # store only layers on top of that.
  home.activation.cupcakeStubInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cupcakeStub="''${XDG_DATA_HOME:-$HOME/.local/share}/cupcake-stub"
    if [[ ! -d "$cupcakeStub/.cupcake/policies/claude" ]]; then
      run ${pkgs.coreutils}/bin/mkdir -p "$cupcakeStub"
      ( cd "$cupcakeStub" && run ${pkgs.cupcake}/bin/cupcake init --harness claude )
    fi
  '';
}
