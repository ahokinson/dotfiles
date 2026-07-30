# Linux-only home packages. Imported by both NixOS and the Asahi standalone
# home-manager profile; use `lib.mkIf` to gate items that the standalone
# profile needs but NixOS provides directly via environment.systemPackages.
# `osConfig` is populated only when home-manager is wired as a NixOS module,
# so `!osConfig ? ...` cleanly identifies the standalone context.
{ pkgs, lib, config, ... }: {
  home.packages = with pkgs; lib.optionals (!config ? osConfig) [
    # ghostty installed via programs.ghostty (home/common/ghostty) instead.
  ];
}