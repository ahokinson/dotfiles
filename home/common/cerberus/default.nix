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
  # `cerberus gate` deny every guarded call. Deployed from the package rather
  # than by `cerberus init`, which rewrites the read-only settings.json.
  home.file.".config/cerberus/rules".source = "${pkgs.cerberus}/share/cerberus/rules";

  # recursive = true for a real directory: a plain source = makes
  # custom/cerberus a read-only store symlink, and `cerberus source sync`
  # installs into sources/ beneath it.
  home.file."${cupcakeStore}/policies/claude/custom/cerberus" = {
    source = "${pkgs.cerberus}/share/cerberus/policies/cupcake";
    recursive = true;
  };

  # The risk head's tirith overlay needs no deployment: cerberus >=0.1.3
  # self-heals it from its embedded copy.

  # cerberus owns this path and pins the commit, so the personal Rego set is
  # a source, not store files. Registered once; updates are applied by hand
  # with `cerberus source sync --yes`.
  home.activation.cerberusPolicySource = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.cerberus}/bin/cerberus source list 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -q '^personal[[:space:]]'; then
      # cerberus shells out to git, which activation's PATH lacks.
      PATH="${pkgs.git}/bin:$PATH" \
        run ${pkgs.cerberus}/bin/cerberus source add \
          personal https://github.com/ahokinson/cupcake.git || \
        warnEcho "cerberus: registering the 'personal' policy source failed"
    fi
  '';
}
