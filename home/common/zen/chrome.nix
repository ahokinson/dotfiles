# The window-controls buttonbox is hidden outright by
# zen.view.experimental-no-window-controls (home/common/zen/data.nix), not
# styled here.
{ pkgs, ... }:
let
  # One pref covers sidebar and toolbar hover-to-peek together, so the
  # toolbar's expand rule is forced off here instead. Neither declaration in
  # zen-styles/zen-compact-mode.css is !important, so this wins over every
  # trigger state, hover included.
  hideToolbarReveal = ''

    #zen-appcontent-navbar-wrapper {
      height: var(--zen-element-separation) !important;
      overflow: clip !important;
    }
  '';
in
{
  userChromeCss = pkgs.writeText "zen-userChrome.css" (
    ''@import "catppuccin/userChrome.css";'' + hideToolbarReveal
  );
  userContentCss = pkgs.writeText "zen-userContent.css" ''@import "catppuccin/userContent.css";'';
}
