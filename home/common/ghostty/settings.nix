# Settings set exhaustively (mirrors the same treatment given to macOS
# system.defaults and Zen), sourced from `ghostty +show-config --default
# --docs`, not just the ones changed from stock. `palette`, `keybind`, and
# `command-palette-entry` are excluded: palette is owned by catppuccin/nix's
# ghostty module (home/common/catppuccin.nix). keybind and
# command-palette-entry are additive in Ghostty's config format, so leaving
# them undeclared already preserves the shipped defaults with no drift risk.
{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # The two palette colors the window chrome needs, matching the
  # background/foreground catppuccin/nix's ghostty module sets from the
  # same underlying Catppuccin Frappe palette.
  palette = import (selfPath "home/common/palette.nix");
  chrome = {
    base = lib.removePrefix "#" palette.base;
    text = lib.removePrefix "#" palette.text;
  };

  # Leaves the header bar carrying nothing but the traffic lights. Has to be
  # CSS (gtk-titlebar = false removes the whole bar, controls included), and
  # has to shrink instead of hide (GTK4 CSS supports neither display nor
  # visibility). Keyed on the window controls' own GTK4 classes, the same
  # ones WhiteSur's own theme selects on.
  headerCss = pkgs.writeText "ghostty-header.css" (
    builtins.readFile (selfPath "home/common/ghostty/_files/header.css")
  );
in
{
  programs.ghostty.settings = {
    macos-icon = "custom-style";
    macos-icon-frame = "beige";
    macos-icon-ghost-color = "737994";
    macos-icon-screen-color = "232634";

    # macOS: "hidden" removes the titlebar entirely; title = " " below
    # blanks the title as defense in depth. Linux/GTK: window-decoration
    # and gtk-custom-css below pare the header bar back to just the window
    # controls.
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
    # background/foreground deliberately NOT pinned here, unlike the rest
    # of this block. The shipped defaults would override whatever the
    # active theme sets, defeating Catppuccin on both platforms.
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
    # no-title: shell integration dynamically setting the window title
    # would override the static blank `title = " "` above.
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
    # theme itself is set by catppuccin/nix's ghostty module, cross-platform.

    # Option key acts as Alt, for terminal/vim-style word-jump bindings.
    macos-option-as-alt = true;
    # Managed by nix (ghostty-bin); disable Sparkle's own auto-update to
    # avoid the binary drifting out from under the nix-pinned version.
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
    # Linux counterpart to the macOS titlebar block above. "client" rather
    # than "auto": auto lets COSMIC draw a server-side titlebar, whose
    # buttons are pinned to the right with no setting to move them. A GTK
    # header bar instead honours gtk-decoration-layout, which
    # home/linux/cosmic/gtk.nix sets to macOS's left-hand
    # close/minimize/zoom order.
    window-decoration = "client";

    linux-cgroup = "never";
    linux-cgroup-hard-fail = false;
    gtk-opengl-debug = false;
    gtk-single-instance = "detect";
    gtk-tabs-location = "top";
    # Stays true. `false` removes the header bar outright, traffic lights
    # and all, instead of reducing it to just the window controls. That
    # paring-down happens via gtk-custom-css instead.
    gtk-titlebar = true;
    gtk-titlebar-hide-when-maximized = false;
    gtk-custom-css = "${headerCss}";

    # "flat" makes the bar continuous with the terminal below it instead of
    # casting a shadow onto it, so the two read as one surface.
    gtk-toolbar-style = "flat";

    # window-theme = "ghostty" is the precondition for the titlebar colors
    # below being honoured at all - they are ignored under "auto". The two
    # colors are the palette's base and text, matching the terminal's own
    # background/foreground so the bar disappears into the window.
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
