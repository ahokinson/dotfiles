{ pkgs, lib, ... }:
let
  cupcakeStore =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/cupcake"
    else
      ".config/cupcake";
in
{
  home.packages = [ pkgs.cerberus ];

  # An empty rules dir is a degraded head, and a degraded head makes
  # `cerberus gate` deny every guarded tool call. Deploying the package's
  # own copies keeps them in lockstep with the binary without running
  # `cerberus init`, which would rewrite the read-only ~/.claude/settings.json.
  home.file.".config/cerberus/rules".source = "${pkgs.cerberus}/share/cerberus/rules";

  # recursive = true so home-manager creates a real directory and symlinks
  # each .rego: a plain source = would make custom/cerberus a read-only store
  # symlink, and `cerberus source sync` installs into sources/ beneath it.
  home.file."${cupcakeStore}/policies/claude/custom/cerberus" = {
    source = "${pkgs.cerberus}/share/cerberus/policies/cupcake";
    recursive = true;
  };

  # cerberus owns this install path and pins the commit itself, so the
  # personal Rego set is a source rather than files from the store.
  # Registered once; `cerberus source sync --yes` applies updates by hand.
  home.activation.cerberusPolicySource = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.cerberus}/bin/cerberus source list 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -q '^personal[[:space:]]'; then
      run ${pkgs.cerberus}/bin/cerberus source add \
        personal https://github.com/ahokinson/cupcake.git || \
        warnEcho "cerberus: registering the 'personal' policy source failed"
    fi
  '';
}
