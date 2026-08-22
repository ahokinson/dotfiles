# macOS traffic lights for Zen's window controls, Linux only (macOS Zen gets
# the real ones from the system).
{ pkgs, lib }:
let
  # Zen draws these buttons itself and only consults GTK's -moz-gtk-csd-*
  # values for placement/order, not appearance — so this has to be chrome
  # CSS rather than the GTK theme (home/linux/cosmic/gtk.nix). Class names
  # verified against the shipped browser/omni.ja.
  zenTrafficLights = ''

    .titlebar-buttonbox-container .titlebar-button {
      appearance: none !important;
      width: 12px !important;
      height: 12px !important;
      min-width: 12px !important;
      min-height: 12px !important;
      padding: 0 !important;
      margin: 0 4px !important;
      border-radius: 50% !important;
    }

    /* The glyphs are Zen's own icons; macOS shows bare circles at rest. */
    .titlebar-buttonbox-container .titlebar-button > .toolbarbutton-icon {
      display: none !important;
    }

    .titlebar-buttonbox-container .titlebar-close {
      background-color: #ff5f57 !important;
    }

    .titlebar-buttonbox-container .titlebar-min {
      background-color: #febc2e !important;
    }

    .titlebar-buttonbox-container .titlebar-max,
    .titlebar-buttonbox-container .titlebar-restore {
      background-color: #28c840 !important;
    }

    /* Unfocused windows lose the colour, same as macOS. */
    .titlebar-buttonbox-container .titlebar-button:-moz-window-inactive {
      background-color: #5b5f6d !important;
    }
  '';
in {
  # The @import has to stay first: CSS ignores @import once other rules have
  # been seen.
  userChromeCss = pkgs.writeText "zen-userChrome.css" (
    ''@import "catppuccin/userChrome.css";''
    + lib.optionalString (!pkgs.stdenv.hostPlatform.isDarwin) zenTrafficLights
  );
  userContentCss = pkgs.writeText "zen-userContent.css" ''@import "catppuccin/userContent.css";'';
}
