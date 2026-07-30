# ghostty config via the home-manager `programs.ghostty` module (available on
# unstable). We declare the user toggles as `settings`; the module writes
# `~/.config/ghostty/config` and validates it on change when a package is in
# scope.
#
# Palette ownership is split by platform:
#   * Linux (NixOS + Asahi): the `catppuccin` home-manager module imported by
#     `home/linux/catppuccin.nix` auto-installs
#     `~/.config/ghostty/themes/catppuccin-frappe` from the upstream
#     catppuccin/ghostty port and sets `settings.theme` for us. Declaring it
#     inline too conflicts on `xdg.configFile`, so we leave it to the catppuccin
#     module there.
#   * macOS: catppuccin module is not imported on darwin, so we declare the
#     Frappe palette inline as `themes.catppuccin-frappe` and set
#     `theme = catppuccin-frappe` ourselves.
#
# Package ownership:
#   * Linux: the HM module installs `pkgs.ghostty` via `home.packages` (default
#     `package`); the orphan `ghostty` entries in `home/linux/packages.nix` /
#     `modules/nixos/base.nix` were removed.
#   * macOS: nixpkgs' `pkgs.ghostty` is Linux-only (no darwin in meta.platforms
#     - upstream lacks a Swift 6/xcodebuild-friendly nixpkgs environment), so
#     we override to `pkgs.ghostty-bin`, which fetches the signed macOS binary
#     directly. No Homebrew involved.
{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.ghostty = {
    enable = true;
    package = lib.mkIf isDarwin pkgs.ghostty-bin;
    enableZshIntegration = true;

    settings = {
      macos-icon = "custom-style";
      macos-icon-frame = "beige";
      macos-icon-ghost-color = "737994";
      macos-icon-screen-color = "232634";

      # Hide the top bar on both platforms. The mechanism has to differ by OS:
      #   * macOS: keep a transparent native titlebar (preserves rounded
      #     corners + native tabs) and just blank its contents.
      #   * Linux/GTK: strip the window decoration entirely.
      # `title = " "` is shared — on macOS it blanks the visible title; on
      # Linux it's inert once the titlebar is gone but harmless.
      macos-titlebar-style = "transparent";
      macos-titlebar-proxy-icon = "hidden";
      title = " ";

      cursor-click-to-move = false;

      font-family = "MesloLGS Nerd Font Mono";
      font-size = 12;
      font-thicken = true;
    } // lib.optionalAttrs isDarwin {
      # On Linux the catppuccin module overrides `theme` with the
      # `light:…,dark:…` form, so only set it here on darwin.
      theme = "catppuccin-frappe";
    } // lib.optionalAttrs (!isDarwin) {
      # Linux counterpart to the macOS titlebar block above.
      window-decoration = false;
    };

    themes = lib.optionalAttrs isDarwin {
      catppuccin-frappe = {
        palette = [
          "0=#51576d"
          "1=#e78284"
          "2=#a6d189"
          "3=#e5c890"
          "4=#8caaee"
          "5=#f4b8e4"
          "6=#81c8be"
          "7=#a5adce"
          "8=#626880"
          "9=#e78284"
          "10=#a6d189"
          "11=#e5c890"
          "12=#8caaee"
          "13=#f4b8e4"
          "14=#81c8be"
          "15=#b5bfe2"
        ];
        background = "303446";
        foreground = "c6d0f5";
        cursor-color = "f2d5cf";
        cursor-text = "232634";
        selection-background = "44495d";
        selection-foreground = "c6d0f5";
      };
    };
  };
}