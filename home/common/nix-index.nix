# Prebuilt nix-index database, refreshed upstream, so no local indexing pass
# is ever needed. Replaces command-not-found, which is backed by a channel
# database a flakes-only system never populates, and adds comma: `, <cmd>`
# runs a binary straight from nixpkgs without installing it.
{ inputs, ... }: {
  imports = [ inputs.nix-index-database.homeModules.default ];

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
