# darwin uses the signed macOS binary directly — nixpkgs' pkgs.ghostty has
# no darwin platform support (upstream lacks a Swift 6/xcodebuild-friendly
# nixpkgs environment).
{ pkgs, ... }:
{
  programs.ghostty.package =
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin
    else pkgs.ghostty;
}
