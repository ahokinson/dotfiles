# Set exhaustively from `ghostty +show-config --default --docs`, stock values
# included. Excluded: palette, owned by catppuccin/nix's ghostty module; and
# keybind and command-palette-entry, which are additive in Ghostty's config
# format and so cannot drift while undeclared.
{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # Ghostty takes these without a leading "#". base and text are the two the
  # window chrome needs, matching what catppuccin/nix's ghostty module sets as
  # background and foreground; the other two colour the macOS app icon.
  palette = import (selfPath "home/common/palette.nix");
  chrome = builtins.mapAttrs (_: lib.removePrefix "#") {
    inherit (palette)
      base
      text
      overlay0
      crust
      ;
  };

in
{
  programs.ghostty.settings = {
    macos-icon = "custom-style";
    macos-icon-frame = "beige";
    macos-icon-ghost-color = chrome.overlay0;
    macos-icon-screen-color = chrome.crust;

    # "hidden" removes the titlebar; the blank title below is belt and
    # braces. The Linux equivalent is window-decoration further down.
    macos-titlebar-style = "hidden";
    title = " ";

    cursor-click-to-move = false;

    font-family = sharedFonts.monoFamily;
    font-size = sharedFonts.pointSize;
    font-thicken = true;

    # --- Everything below pins the shipped default explicitly ----------
    font-style = "default";
    font-style-bold = "default";
    font-style-italic = "default";
    font-style-bold-italic = "default";
    font-synthetic-style = "bold,italic,bold-italic";
    font-thicken-strength = 255;
    font-shaping-break = "cursor";
    alpha-blending = "native";
    grapheme-width-method = "unicode";
    # background/foreground are the exception: pinning their shipped
    # defaults would override the active theme.
    background-image-opacity = 1;
    background-image-position = "center";
    background-image-fit = "contain";
    background-image-repeat = false;
    selection-clear-on-typing = true;
    selection-clear-on-copy = false;
    minimum-contrast = 1;
    cursor-style = "block";
    cursor-opacity = 1;
    mouse-hide-while-typing = false;
    scroll-to-bottom = "keystroke,no-output";
    mouse-shift-capture = false;
    mouse-reporting = true;
    mouse-scroll-multiplier = "precision:1,discrete:3";
    background-opacity = 1;
    background-opacity-cells = false;
    background-blur = false;
    unfocused-split-opacity = 0.7;
    split-preserve-zoom = "no-navigation";
    search-foreground = "#000000";
    search-background = "#ffe082";
    search-selected-foreground = "#000000";
    search-selected-background = "#f2a57e";
    notify-on-command-finish = "never";
    notify-on-command-finish-action = "bell,no-notify";
    notify-on-command-finish-after = "5s";
    wait-after-command = false;
    abnormal-command-exit-runtime = 250;
    scrollback-limit = 10000000;
    scrollbar = "system";
    link-url = true;
    link-previews = true;
    maximize = false;
    fullscreen = false;
    window-padding-x = 2;
    window-padding-y = 2;
    window-padding-balance = false;
    window-padding-color = "background";
    window-vsync = true;
    window-inherit-working-directory = true;
    tab-inherit-working-directory = true;
    split-inherit-working-directory = true;
    window-inherit-font-size = true;
    window-subtitle = false;
    window-theme = "auto";
    window-colorspace = "srgb";
    window-save-state = "default";
    window-step-resize = false;
    window-new-tab-position = "current";
    window-show-tab-bar = "auto";
    resize-overlay = "after-first";
    resize-overlay-position = "center";
    resize-overlay-duration = "750ms";
    focus-follows-mouse = false;
    clipboard-read = "ask";
    clipboard-write = "allow";
    clipboard-trim-trailing-spaces = true;
    clipboard-paste-protection = true;
    clipboard-paste-bracketed-safe = true;
    title-report = false;
    image-storage-limit = 320000000;
    copy-on-select = true;
    right-click-action = "context-menu";
    click-repeat-interval = 0;
    config-default-files = true;
    confirm-close-surface = true;
    quit-after-last-window-closed = false;
    initial-window = true;
    undo-timeout = "5s";
    shell-integration = "detect";
    # no-title: shell integration would otherwise override the blank title.
    shell-integration-features = "cursor,no-sudo,no-title,no-ssh-env,no-ssh-terminfo,path";
    osc-color-report-format = "16-bit";
    vt-kam-allowed = false;
    custom-shader-animation = true;
    bell-features = "no-system,no-audio,attention,title,no-border";
    bell-audio-volume = 0.5;
    app-notifications = "clipboard-copy,config-reload";
    desktop-notifications = true;
    progress-style = true;
    faint-opacity = 0.5;
    term = "xterm-ghostty";
    async-backend = "auto";
  }
  // lib.optionalAttrs isDarwin {
    # Option acts as Alt, for word-jump bindings.
    macos-option-as-alt = true;
    # ghostty-bin is nix-pinned; Sparkle would update the binary underneath it.
    auto-update = "off";

    macos-non-native-fullscreen = false;
    macos-window-buttons = "visible";
    macos-dock-drop-behavior = "new-tab";
    macos-window-shadow = true;
    macos-hidden = "never";
    macos-auto-secure-input = true;
    macos-secure-input-indication = true;
    macos-applescript = true;
    macos-shortcuts = "ask";
  }
  // lib.optionalAttrs (!isDarwin) {
    # No titlebar or window controls; COSMIC keybinds replace them
    # (home/linux/cosmic/shortcuts.nix). "none" drops the whole frame, unlike
    # gtk-titlebar = false, which leaves rounded corners and a bare bar.
    window-decoration = "none";

    linux-cgroup = "never";
    linux-cgroup-hard-fail = false;
    gtk-opengl-debug = false;
    gtk-single-instance = "detect";
    gtk-tabs-location = "top";

    # The titlebar colors below are ignored under "auto"; this is what makes
    # them apply.
    window-theme = "ghostty";
    window-titlebar-background = chrome.base;
    window-titlebar-foreground = chrome.text;
    gtk-wide-tabs = true;
    quick-terminal-position = "top";
    gtk-quick-terminal-layer = "top";
    gtk-quick-terminal-namespace = "ghostty-quick-terminal";
    quick-terminal-screen = "main";
    quick-terminal-animation-duration = 0.2;
    quick-terminal-autohide = true;
    quick-terminal-space-behavior = "move";
    quick-terminal-keyboard-interactivity = "on-demand";
  };
}
