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
#
# Settings below are set exhaustively (mirrors the same treatment given to
# macOS system.defaults and Zen), sourced from `ghostty +show-config
# --default --docs` — not just the ones changed from stock. `palette`,
# `keybind`, and `command-palette-entry` are excluded: palette is owned by
# the theme above, and keybind/command-palette-entry are additive in
# Ghostty's config format, so leaving them undeclared already preserves the
# shipped defaults with no drift risk.
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
      #   * macOS: "hidden" removes the titlebar entirely (unlike
      #     "transparent", which keeps the native bar and just makes it
      #     see-through — title/cwd text still renders on top of it).
      #   * Linux/GTK: strip the window decoration entirely.
      # `title = " "` is shared, kept as a defense-in-depth blank default.
      macos-titlebar-style = "hidden";
      title = " ";

      cursor-click-to-move = false;

      font-family = "MesloLGS Nerd Font Mono";
      font-size = 12;
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
      # background/foreground deliberately NOT pinned here (unlike the rest
      # of this block) — the shipped defaults would override whatever the
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
    } // lib.optionalAttrs isDarwin {
      # On Linux the catppuccin module overrides `theme` with the
      # `light:…,dark:…` form, so only set it here on darwin.
      theme = "catppuccin-frappe";

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
    } // lib.optionalAttrs (!isDarwin) {
      # Linux counterpart to the macOS titlebar block above.
      window-decoration = false;

      linux-cgroup = "never";
      linux-cgroup-hard-fail = false;
      gtk-opengl-debug = false;
      gtk-single-instance = "detect";
      gtk-tabs-location = "top";
      gtk-titlebar-hide-when-maximized = false;
      gtk-toolbar-style = "raised";
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
