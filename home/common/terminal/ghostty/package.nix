# darwin takes the signed macOS binary: pkgs.ghostty has no darwin platform
# support.
{ pkgs, ... }:
{
  programs.ghostty.package =
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
}
