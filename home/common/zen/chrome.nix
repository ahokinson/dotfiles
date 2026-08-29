# Zen's own window-controls buttonbox is hidden entirely via
# zen.view.experimental-no-window-controls (home/common/zen/data.nix)
# instead of styled here - this used to draw macOS-style traffic lights over
# it by hand, retired along with ghostty's and signal's and vesktop's own
# title bars.
{ pkgs, ... }:
let
  # zen.view.compact.show-sidebar-and-toolbar-on-hover stays on (it's the
  # only pref for either), so the sidebar keeps its hover-to-peek. This
  # forces just the toolbar's own expand rule back off. Checked against the
  # shipped zen-styles/zen-compact-mode.css: #zen-appcontent-navbar-wrapper
  # collapses to `height: var(--zen-element-separation)` at rest and expands
  # to `height: var(--zen-toolbar-height-with-bookmarks)` when it or a
  # descendant matches :is([zen-has-hover], [has-popup-menu],
  # [zen-compact-mode-active]) - neither declaration is !important, so this
  # unconditionally wins over every trigger state, hover included.
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
