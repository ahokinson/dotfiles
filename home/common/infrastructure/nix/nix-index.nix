# Prebuilt database, so there is never a local indexing pass. Replaces
# command-not-found, whose channel database a flakes-only system never
# populates. Also brings comma: `, <cmd>` runs a binary without installing it.
{ inputs, ... }: {
  imports = [ inputs.nix-index-database.homeModules.default ];

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
