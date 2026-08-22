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
#   * NixOS: the HM module installs `pkgs.ghostty` via `home.packages` (default
#     `package`); the orphan `ghostty` entries in `home/linux/packages.nix` /
#     `modules/nixos/base.nix` were removed.
#   * macOS: nixpkgs' `pkgs.ghostty` is Linux-only (no darwin in meta.platforms
#     - upstream lacks a Swift 6/xcodebuild-friendly nixpkgs environment), so
#     we override to `pkgs.ghostty-bin`, which fetches the signed macOS binary
#     directly. No Homebrew involved.
#   * Asahi: `pkgs.ghostty` is a Nix-built Linux binary, and confirmed on
#     real hardware: it fails with "unable to acquire an opengl context for
#     rendering". Per Ghostty's own docs
#     (ghostty.org/docs/help/gtk-opengl-context), this is "always an
#     environment issue" - GTK4's GSK renderer is version-locked to nixpkgs'
#     own Mesa/libwayland as a whole unit, not just a driver-path lookup. A
#     narrower fix (LIBGL_DRIVERS_PATH/__EGL_VENDOR_LIBRARY_DIRS only) was
#     tried and confirmed insufficient on real hardware - it covers classic
#     DRI/GLVND driver lookup but not GTK4's own bundled
#     libwayland-client/libwayland-egl linkage. `ghosttyAsahiGl` below goes
#     further: at launch time (not Nix build time - these have to come from
#     whatever Fedora actually has installed right now, not something
#     baked ahead of time) it symlinks Fedora's own libwayland-client/
#     libwayland-egl/libwayland-cursor/libEGL/libGL/libGLX/libgbm/libdrm
#     into a small cache dir and prepends only that dir to
#     LD_LIBRARY_PATH - narrower than overriding the whole /usr/lib64 (which
#     would also swap glib/pango/cairo/etc. underneath Nix's GTK4, a much
#     bigger surface for a symbol-version clash), but broader than the
#     driver-path-only attempt. This is genuinely untested and past what
#     even nix-gl-host currently supports for Mesa (its own docs mark that
#     path unsupported) - confirm on real hardware and adjust the library
#     list if it's still failing or fails differently (mismatched-symbol
#     crashes rather than a clean GL error would mean this made it worse,
#     not better) - fall back to `package = null` + dnf, same split as
#     kvantum-asahi.nix, if it doesn't pan out.
#
# Settings below are set exhaustively (mirrors the same treatment given to
# macOS system.defaults and Zen), sourced from `ghostty +show-config
# --default --docs` — not just the ones changed from stock. `palette`,
# `keybind`, and `command-palette-entry` are excluded: palette is owned by
# the theme above, and keybind/command-palette-entry are additive in
# Ghostty's config format, so leaving them undeclared already preserves the
# shipped defaults with no drift risk.
{ pkgs, lib, selfPath, osConfig ? null, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };

  # The two Catppuccin Frappe colors the window chrome needs, matching the
  # palette's own background/foreground (see the catppuccin-frappe theme
  # below, which repeats them for darwin).
  frappe = {
    base = "303446";
    text = "c6d0f5";
  };

  # Leaves the header bar carrying nothing but the traffic lights.
  #
  # It has to be CSS because ghostty has no setting for this - the only
  # nearby switch, gtk-titlebar = false, removes the whole bar including the
  # window controls. And it has to *shrink* rather than hide, because GTK4
  # CSS supports neither display nor visibility.
  #
  # Keyed on the window controls' own classes rather than on position in the
  # widget tree. Structure is the wrong thing to match here: `windowcontrols`
  # lives *inside* box.start alongside ghostty's widgets, so a descendant
  # selector would catch the traffic lights too, while a direct-child one
  # misses the new-tab/dropdown pair because they sit in their own linked box.
  # close/minimize/maximize are the classes GTK4 puts on the control buttons -
  # the same ones WhiteSur's own theme selects on.
  headerbarCss = pkgs.writeText "ghostty-headerbar.css" ''
    headerbar button:not(.close):not(.minimize):not(.maximize),
    headerbar menubutton {
      opacity: 0;
      min-width: 0;
      min-height: 0;
      padding: 0;
      margin: 0;
      -gtk-icon-size: 0;
    }

    /* The title label. `title = " "` should already blank it, but ghostty
       falls back to a dynamic title when the value parses as empty. */
    headerbar windowtitle,
    headerbar label {
      opacity: 0;
    }

    /* No seam between the bar and the terminal: gtk-toolbar-style = flat
       drops the shadow, this drops the border WhiteSur draws under it. */
    .window headerbar {
      border: none;
      box-shadow: none;
    }
  '';
  # osConfig is a specialArg home-manager injects only when wired in as a
  # NixOS module - absent (default null) for the standalone Asahi profile,
  # same test used in home/linux/plasma-panel.nix and friends.
  isAsahi = !isDarwin && osConfig == null;

  ghosttyAsahiGl = pkgs.symlinkJoin {
    name = "ghostty-asahi-gl";
    paths = [ pkgs.ghostty ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ghostty --run '
        libdir="$HOME/.cache/ghostty-asahi-gl-libs"
        mkdir -p "$libdir"
        for pattern in "libwayland-*.so*" "libEGL*.so*" "libGL*.so*" "libOpenGL*.so*" "libgbm.so*" "libdrm*.so*"; do
          for f in /usr/lib64/$pattern /usr/lib/$pattern; do
            [ -e "$f" ] && ln -sf "$f" "$libdir/$(basename "$f")"
          done
        done
        export LD_LIBRARY_PATH="$libdir:$LD_LIBRARY_PATH"
        export LIBGL_DRIVERS_PATH=/usr/lib64/dri
        export __EGL_VENDOR_LIBRARY_DIRS=/usr/share/glvnd/egl_vendor.d
      '

      # symlinkJoin only symlinks these through unchanged, and both bake an
      # absolute Exec=/ExecStart= path straight to ghostty's own unwrapped
      # store path - the .desktop launch (and D-Bus activation, since it's
      # DBusActivatable) would otherwise bypass this wrapper entirely and go
      # straight to the unwrapped binary. Regenerate both pointing at
      # $out/bin/ghostty instead.
      rm -f $out/share/applications/com.mitchellh.ghostty.desktop
      sed "s|${pkgs.ghostty}/bin/ghostty|$out/bin/ghostty|g" \
        ${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop \
        > $out/share/applications/com.mitchellh.ghostty.desktop

      rm -f $out/share/systemd/user/app-com.mitchellh.ghostty.service
      sed "s|${pkgs.ghostty}/bin/ghostty|$out/bin/ghostty|g" \
        ${pkgs.ghostty}/share/systemd/user/app-com.mitchellh.ghostty.service \
        > $out/share/systemd/user/app-com.mitchellh.ghostty.service
    '';
    # symlinkJoin doesn't carry the wrapped package's meta over, and
    # lib.getExe (used for the +validate-config check below, and by
    # anything else that resolves the binary name from meta.mainProgram)
    # would otherwise guess "ghostty-asahi-gl" from this derivation's own
    # name - which doesn't exist in $out/bin, only "ghostty" does.
    meta = pkgs.ghostty.meta // { mainProgram = "ghostty"; };
  };
in
{
  programs.ghostty = {
    enable = true;
    package =
      if isDarwin then pkgs.ghostty-bin
      else if isAsahi then ghosttyAsahiGl
      else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      macos-icon = "custom-style";
      macos-icon-frame = "beige";
      macos-icon-ghost-color = "737994";
      macos-icon-screen-color = "232634";

      # The two platforms diverge on the top bar:
      #   * macOS: "hidden" removes the titlebar entirely (unlike
      #     "transparent", which keeps the native bar and just makes it
      #     see-through — title/cwd text still renders on top of it), and
      #     `title = " "` below blanks the title as defense in depth.
      #   * Linux/GTK: a header bar pared back to just the window controls -
      #     see window-decoration and gtk-custom-css in the !isDarwin block.
      # `title = " "` is shared: neither platform shows title text.
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
      # Stays true: `false` removes the header bar outright, traffic lights
      # and all, rather than reducing it to the window controls. Paring it
      # down to just those is done in headerbar.css instead.
      gtk-titlebar = true;
      gtk-titlebar-hide-when-maximized = false;
      gtk-custom-css = "${headerbarCss}";

      # "flat" makes the bar continuous with the terminal below it instead of
      # casting a shadow onto it, so the two read as one surface.
      gtk-toolbar-style = "flat";

      # window-theme = "ghostty" is the precondition for the titlebar colors
      # below being honoured at all - they are ignored under "auto". The two
      # colors are Frappe base and text, matching the terminal's own
      # background/foreground so the bar disappears into the window.
      window-theme = "ghostty";
      window-titlebar-background = frappe.base;
      window-titlebar-foreground = frappe.text;
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
