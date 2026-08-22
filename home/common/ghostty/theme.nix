# On Linux the catppuccin home-manager module (home/linux/catppuccin.nix)
# installs this theme and sets programs.ghostty.settings.theme itself;
# declaring it here too would conflict on xdg.configFile. macOS doesn't
# import that module, so the Frappe palette is declared inline here instead.
{ pkgs, lib, ... }: {
  programs.ghostty.themes = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
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
}
