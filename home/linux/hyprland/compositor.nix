# Second session alongside COSMIC (home/linux/cosmic).
{
  lib,
  pkgs,
  selfPath,
  osConfig ? null,
  ...
}:
let
  terminal = "ghostty"; # desktop-cosmic.nix excludes cosmic-term for the same terminal
  menu = "fuzzel";
  browser = "zen-beta"; # home/common/zen's package/binary name

  # Same wallpaper selection as wallpaper.nix/lock.nix, re-derived
  # independently here rather than sharing one binding, matching this
  # directory's existing convention - needed below to re-apply it past
  # hyprpaper's own startup race (see the hyprland.start hook).
  isApple = (import (selfPath "home/common/host.nix") { inherit osConfig; }).isApple;
  wallpaper = selfPath (
    if isApple then "home/common/_files/wallpaper/asahi.jpg" else "home/common/_files/wallpaper/nix.jpg"
  );

  # Wraps a raw Lua expression so it renders as Lua source instead of a
  # quoted string - used both for dispatcher calls and for referencing the
  # `colors` local catppuccin.autoEnable injects (see catppuccin.hyprland
  # below).
  lua = expr: lib.generators.mkLuaInline expr;

  bind = keys: dispatcher: { _args = [ keys dispatcher ]; };
  bindOpts = keys: dispatcher: opts: { _args = [ keys dispatcher opts ]; };
in
{
  # brightnessctl backs the XF86MonBrightness binds below. wpctl (volume
  # binds) and playerctl (media binds) need no addition here - wpctl ships
  # with modules/nixos/audio.nix's pipewire/wireplumber, playerctl is already
  # on $PATH system-wide. hyprpaper is needed explicitly since
  # wallpaper.nix's package = null drops it from services.hyprpaper's own
  # wiring; waybar.nix's programs.waybar.enable already adds waybar itself.
  home.packages = [
    pkgs.brightnessctl
    pkgs.hyprpaper
  ];

  # home/common/catppuccin.nix's global accent is mauve; overridden to blue
  # here to match home/linux/cosmic/theme.nix's own accent override, so the
  # two sessions' borders match instead of one going mauve, one blue.
  catppuccin.hyprland.accent = "blue";

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Portal wiring (xdg-desktop-portal-hyprland) comes from
    # desktop-hyprland.nix's programs.hyprland.enable at the system level;
    # this module's xdph option only tunes its config file, not whether it
    # runs, so there's nothing to disable here.

    # Pinned explicitly rather than left at home-manager's default: this
    # matches catppuccin.autoEnable's Hyprland theming (home/linux/catppuccin.nix),
    # which writes a Lua-only `colors._var = require('themes.catppuccin')`
    # block with no hyprlang fallback. If this were "hyprlang" that block
    # renders as invalid nested categories instead of a Lua local.
    configType = "lua";

    settings = {
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        # bookpro14-m1-pro's panel is Retina - scale is a logical-resolution
        # divisor, not a size multiplier, so 2 here means the same
        # physical/2 logical resolution macOS's own default Retina scaling
        # uses (e.g. 3024x1964 physical -> 1512x982 logical).
        scale = 2;
      };

      config = {
        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };

        misc.disable_splash_rendering = true;

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          layout = "dwindle";

          col = {
            active_border = lua "colors.accent";
            inactive_border = lua "colors.overlay0";
          };
        };
        input.touchpad.natural_scroll = false;

        decoration.rounding = 8;
      };

      # Both are systemd-disabled in their own modules (waybar.nix,
      # wallpaper.nix) - launched directly here instead, matching Hyprland's
      # own stock config, which documents exactly this hl.on("hyprland.start",
      # ...) pattern for status bars and wallpaper daemons.
      #
      on = {
        _args = [
          "hyprland.start"
          (lua ''
            function()
              -- hyprctl layers confirms waybar's own surface is correctly
              -- sized (1512x32 - the right logical width at this host's
              -- scale=2), so the right-side module group rendering past
              -- the edge is GTK's own internal layout math, not the
              -- surface allocation. GDK_SCALE=1 stops GTK from re-applying
              -- its own scale-aware sizing on top of Hyprland's already-
              -- correct one.
              hl.exec_cmd("GDK_SCALE=1 waybar")
              hl.exec_cmd("hyprpaper")
            end
          '')
        ];
      };

      bind =
        [
          (bind "SUPER + Return" (lua ''hl.dsp.exec_cmd("${terminal}")''))
          (bind "SUPER + D" (lua ''hl.dsp.exec_cmd("${menu}")''))
          (bind "SUPER + B" (lua ''hl.dsp.exec_cmd("${browser}")'')) # mirrors COSMIC's stock Super+B web browser key
          (bind "SUPER + Q" (lua "hl.dsp.window.close()")) # mirrors COSMIC's own Super+Q close
          (bind "SUPER + M" (lua "hl.dsp.window.fullscreen()")) # mirrors COSMIC's own Super+M maximize
          (bind "SUPER + F" (lua ''hl.dsp.window.float({ action = "toggle" })''))
          (bind "SUPER + R" (lua ''hl.dsp.exec_cmd("hyprctl reload")''))

          # Lock/exit use COSMIC's own Escape pair instead of L/Shift+Q,
          # freeing L for movefocus below and keeping this one pair
          # identical across both DEs' sessions.
          (bind "SUPER + Escape" (lua ''hl.dsp.exec_cmd("hyprlock")''))
          (bind "SUPER + SHIFT + Escape" (lua "hl.dsp.exit()"))

          # Directional focus/move, vim-style.
          (bind "SUPER + H" (lua ''hl.dsp.focus({ direction = "left" })''))
          (bind "SUPER + J" (lua ''hl.dsp.focus({ direction = "down" })''))
          (bind "SUPER + K" (lua ''hl.dsp.focus({ direction = "up" })''))
          (bind "SUPER + L" (lua ''hl.dsp.focus({ direction = "right" })''))
          # window.move's direction key isn't shown in Hyprland's own stock
          # config (only its workspace key is) - inferred from focus's
          # direction key using the same table shape. Worth checking first
          # if Shift+hjkl doesn't move the window.
          (bind "SUPER + SHIFT + H" (lua ''hl.dsp.window.move({ direction = "left" })''))
          (bind "SUPER + SHIFT + J" (lua ''hl.dsp.window.move({ direction = "down" })''))
          (bind "SUPER + SHIFT + K" (lua ''hl.dsp.window.move({ direction = "up" })''))
          (bind "SUPER + SHIFT + L" (lua ''hl.dsp.window.move({ direction = "right" })''))

          # Same grid, one monitor over. framework13-amd-ryzen runs at most
          # one external display, so only left/right ever fire - up/down are
          # no-ops without a third monitor above or below. The monitor key
          # on focus/window.move is inferred the same way as direction above
          # (no monitor-switching dispatcher appears in Hyprland's own
          # examples) - the first thing to check if these don't work.
          (bind "SUPER + CONTROL + H" (lua ''hl.dsp.focus({ monitor = "left" })''))
          (bind "SUPER + CONTROL + J" (lua ''hl.dsp.focus({ monitor = "down" })''))
          (bind "SUPER + CONTROL + K" (lua ''hl.dsp.focus({ monitor = "up" })''))
          (bind "SUPER + CONTROL + L" (lua ''hl.dsp.focus({ monitor = "right" })''))
          (bind "SUPER + CONTROL + SHIFT + H" (lua ''hl.dsp.window.move({ monitor = "left" })''))
          (bind "SUPER + CONTROL + SHIFT + J" (lua ''hl.dsp.window.move({ monitor = "down" })''))
          (bind "SUPER + CONTROL + SHIFT + K" (lua ''hl.dsp.window.move({ monitor = "up" })''))
          (bind "SUPER + CONTROL + SHIFT + L" (lua ''hl.dsp.window.move({ monitor = "right" })''))

          (bind "SUPER + S" (lua ''hl.dsp.layout("togglesplit")'')) # dwindle only
          (bind "SUPER + Tab" (lua "hl.dsp.window.cycle_next()"))
          # `previous` is inferred - the reverse-direction key isn't shown in
          # Hyprland's own examples either.
          (bind "SUPER + SHIFT + Tab" (lua "hl.dsp.window.cycle_next({ previous = true })"))
          (bind "SUPER + SHIFT + R" (lua ''hl.dsp.submap("resize")''))

          # Relative workspace cycling, keyboard and scroll wheel.
          (bind "SUPER + bracketleft" (lua ''hl.dsp.focus({ workspace = "e-1" })''))
          (bind "SUPER + bracketright" (lua ''hl.dsp.focus({ workspace = "e+1" })''))
          (bind "SUPER + mouse_down" (lua ''hl.dsp.focus({ workspace = "e+1" })''))
          (bind "SUPER + mouse_up" (lua ''hl.dsp.focus({ workspace = "e-1" })''))
        ]
        ++ (map (
          i: bind "SUPER + ${toString i}" (lua "hl.dsp.focus({ workspace = ${toString i} })")
        ) (lib.range 1 9))
        ++ (map (
          i:
          bind "SUPER + SHIFT + ${toString i}" (lua "hl.dsp.window.move({ workspace = ${toString i} })")
        ) (lib.range 1 9))
        ++ [
          # Ctrl+Shift+3/4 mimic macOS's screenshot shortcuts, the same
          # convention home/linux/cosmic/shortcuts.nix uses.
          (bind "CONTROL + SHIFT + 3" (lua ''
            hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png")
          ''))
          (bind "CONTROL + SHIFT + 4" (lua ''
            hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png")
          ''))

          (bindOpts "SUPER + mouse:272" (lua "hl.dsp.window.drag()") { mouse = true; })
          (bindOpts "SUPER + mouse:273" (lua "hl.dsp.window.resize()") { mouse = true; })

          # No modifier - these keys have no other purpose, matching COSMIC's
          # own convention of binding XF86 keys bare. locked = fires even
          # while hyprlock is active.
          (bindOpts "XF86AudioMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'') {
            locked = true;
          })
          (bindOpts "XF86AudioMicMute" (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'') {
            locked = true;
          })
          (bindOpts "XF86AudioPlay" (lua ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; })
          (bindOpts "XF86AudioNext" (lua ''hl.dsp.exec_cmd("playerctl next")'') { locked = true; })
          (bindOpts "XF86AudioPrev" (lua ''hl.dsp.exec_cmd("playerctl previous")'') { locked = true; })

          # repeating = fires again while the key is held. Volume is capped
          # at 100% so repeated presses can't push it past that.
          (bindOpts "XF86AudioRaiseVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'') {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86AudioLowerVolume" (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'') {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86MonBrightnessUp" (lua ''hl.dsp.exec_cmd("brightnessctl set 5%+")'') {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86MonBrightnessDown" (lua ''hl.dsp.exec_cmd("brightnessctl set 5%-")'') {
            locked = true;
            repeating = true;
          })
          # XF86PowerOff is left unbound - systemd-logind already owns the
          # physical power key; binding it here too would double-fire it.
        ];
    };

    # Resize mode: Super+Shift+R enters it, hjkl resizes the active window
    # in 10px steps, Escape/Return leaves it.
    submaps.resize.settings.bind = [
      (bindOpts "l" (lua "hl.dsp.window.resize({ x = 10, y = 0, relative = true })") { repeating = true; })
      (bindOpts "h" (lua "hl.dsp.window.resize({ x = -10, y = 0, relative = true })") { repeating = true; })
      (bindOpts "k" (lua "hl.dsp.window.resize({ x = 0, y = -10, relative = true })") { repeating = true; })
      (bindOpts "j" (lua "hl.dsp.window.resize({ x = 0, y = 10, relative = true })") { repeating = true; })
      (bind "Escape" (lua ''hl.dsp.submap("reset")''))
      (bind "Return" (lua ''hl.dsp.submap("reset")''))
    ];
  };
}
