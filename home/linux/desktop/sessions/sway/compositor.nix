# Second session alongside COSMIC (home/linux/desktop/sessions/cosmic), replacing Hyprland in
# that slot. config = null + extraConfig throughout this directory rather
# than home-manager's typed wayland.windowManager.sway.config: Sway's native
# text format is already declarative and stable, and this keeps every file
# free to append its own lines (types.lines concatenates) without fighting
# partial typed coverage of newer directives like bindgesture.
{
  lib,
  pkgs,
  selfPath,
  osConfig ? null,
  ...
}:
let
  terminal = "ghostty"; # modules/nixos/desktop/cosmic.nix excludes cosmic-term for the same terminal
  menu = "fuzzel";
  browser = "zen-beta"; # home/common/apps/browsers/zen's package/binary name

  palette = import (selfPath "home/common/theme/palette.nix");

  # This host's built-in panel scale - used below only for the output scale.
  # Each file in this directory computes this itself rather than importing
  # one shared value, so any single file can be read on its own without an
  # import chain.
  inherit ((import (selfPath "home/common/lib/host.nix") { inherit osConfig; })) displayScale;

  workspaceBinds = lib.concatMapStringsSep "\n" (i: ''
    bindsym $mod+${toString i} workspace number ${toString i}
    bindsym $mod+Shift+${toString i} move container to workspace number ${toString i}
  '') (lib.range 1 9);
in
{
  # brightnessctl backs osd.nix's swayosd-client brightness calls. wpctl
  # (volume) and playerctl (media binds) need no addition here - wpctl ships
  # with modules/nixos/core/audio.nix's pipewire/wireplumber, playerctl is
  # already on $PATH system-wide.
  home.packages = [
    pkgs.brightnessctl
  ];

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true; # lets pavucontrol pick up cursor/theme via gsettings

    config = null;

    extraConfig = ''
      set $mod Mod4

      floating_modifier $mod

      gaps inner 4
      gaps outer 4
      default_border pixel 2
      default_floating_border pixel 2

      # class            border    background  text        indicator  child_border
      client.focused      ${palette.blue}  ${palette.blue}  ${palette.base}  ${palette.blue}  ${palette.blue}
      client.unfocused    ${palette.overlay0}  ${palette.base}  ${palette.text}  ${palette.overlay0}  ${palette.overlay0}

      # Built-in panel only - external monitors (all of studio-m1-max's
      # outputs, or anything plugged into framework13-amd-ryzen/
      # bookpro14-m1-pro) stay at native scale until profiled individually
      # via swaymsg -t get_outputs.
      output "*" scale 1
      output eDP-1 scale ${displayScale}

      input type:touchpad natural_scroll disabled

      # app_id matches native Wayland clients; class is the XWayland fallback.
      for_window [app_id="^org\.pulseaudio\.pavucontrol$"] floating enable
      for_window [class="^org\.pulseaudio\.pavucontrol$"] floating enable
      # No percentage-arithmetic corner-pin here (Sway's move position has no
      # equivalent to Hyprland's "100%-w-20 100%-h-20") - floating + sticky
      # only, positioned wherever it opens.
      for_window [title="^Picture-in-Picture$"] floating enable, sticky enable

      bindsym $mod+Return exec ${terminal}
      bindsym $mod+d exec ${menu}
      bindsym $mod+b exec ${browser} # mirrors COSMIC's stock Super+B web browser key
      # Explicit only: LifeSaver is never attached to idle or locking.
      bindsym $mod+Ctrl+g exec lifesaver
      bindsym $mod+q kill # mirrors COSMIC's own Super+Q close
      bindsym $mod+m fullscreen toggle # mirrors COSMIC's own Super+M maximize
      bindsym $mod+f floating toggle
      bindsym $mod+r reload

      # Lock/exit use COSMIC's own Escape pair instead of L/Shift+Q, freeing L
      # for focus below and keeping this one pair identical across both
      # sessions. This doesn't invoke a screen locker directly: it broadcasts
      # ext-session-lock-v1 over logind, which cosmic-greeter-daemon answers
      # by drawing the actual lock screen.
      bindsym $mod+Escape exec loginctl lock-session
      bindsym $mod+Shift+Escape exit

      bindsym $mod+v exec bash -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'

      # Sway's own scratchpad, not a borrowed special workspace.
      bindsym $mod+grave scratchpad show
      bindsym $mod+Shift+grave move scratchpad

      # Directional focus/move, vim-style.
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right
      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+l move right

      # Same grid, one monitor over. framework13-amd-ryzen runs at most one
      # external display, so only left/right ever fire - up/down are no-ops
      # without a third monitor above or below.
      bindsym $mod+Ctrl+h focus output left
      bindsym $mod+Ctrl+j focus output down
      bindsym $mod+Ctrl+k focus output up
      bindsym $mod+Ctrl+l focus output right
      bindsym $mod+Ctrl+Shift+h move container to output left
      bindsym $mod+Ctrl+Shift+j move container to output down
      bindsym $mod+Ctrl+Shift+k move container to output up
      bindsym $mod+Ctrl+Shift+l move container to output right

      # No dwindle here - Sway has no auto-tiling algorithm to select, only
      # its own manual split tree, so this toggles the focused container's
      # split orientation instead of a whole-tree layout mode.
      bindsym $mod+s layout toggle split
      # Sibling-order cycling, not MRU alt-tab - Sway has no MRU primitive.
      bindsym $mod+Tab focus next
      bindsym $mod+Shift+Tab focus prev
      bindsym $mod+Shift+r mode "resize"

      # Relative workspace cycling, keyboard and scroll wheel.
      bindsym $mod+bracketleft workspace prev
      bindsym $mod+bracketright workspace next
      bindsym $mod+button4 workspace prev
      bindsym $mod+button5 workspace next

      ${workspaceBinds}

      # Ctrl+Shift+3/4 mimic macOS's screenshot shortcuts, the same
      # convention home/linux/desktop/sessions/cosmic/shortcuts.nix uses.
      bindsym Ctrl+Shift+3 exec grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
      bindsym Ctrl+Shift+4 exec grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png

      # $mod+left-drag moves a floating window, $mod+right-drag resizes one -
      # Sway's own convention, replacing Hyprland's explicit mouse binds.

      # No modifier - these keys have no other purpose, matching COSMIC's own
      # convention of binding XF86 keys bare. --locked fires even while
      # cosmic-greeter's lock screen is up. swayosd-client runs the
      # underlying wpctl/brightnessctl call itself and shows the OSD.
      # --no-repeat: held keys auto-repeat by default, which would refire a
      # toggle on every repeat tick.
      bindsym --no-repeat --locked XF86AudioMute exec swayosd-client --output-volume mute-toggle
      bindsym --no-repeat --locked XF86AudioMicMute exec swayosd-client --input-volume mute-toggle
      bindsym --no-repeat --locked XF86AudioPlay exec playerctl play-pause
      bindsym --no-repeat --locked XF86AudioNext exec playerctl next
      bindsym --no-repeat --locked XF86AudioPrev exec playerctl previous
      # Raise/lower keep the default auto-repeat-while-held behavior.
      bindsym --locked XF86AudioRaiseVolume exec swayosd-client --output-volume raise
      bindsym --locked XF86AudioLowerVolume exec swayosd-client --output-volume lower
      bindsym --locked XF86MonBrightnessUp exec swayosd-client --brightness raise
      bindsym --locked XF86MonBrightnessDown exec swayosd-client --brightness lower
      # XF86PowerOff is left unbound - systemd-logind already owns the
      # physical power key; binding it here too would double-fire it.

      # 3-finger horizontal touchpad swipe -> workspace switch. bindgesture
      # is a relatively recent addition - confirm the pinned nixpkgs' sway
      # has it if this doesn't fire.
      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next

      # Resize mode: Super+Shift+R enters it, hjkl resizes the active window
      # in 10px steps, Escape/Return leaves it. Sway's literal submap
      # equivalent.
      mode "resize" {
        bindsym h resize shrink width 10px
        bindsym j resize grow height 10px
        bindsym k resize shrink height 10px
        bindsym l resize grow width 10px
        bindsym Escape mode "default"
        bindsym Return mode "default"
      }

      # Waybar is exec'd directly rather than through a home-manager systemd
      # unit, since this session does not activate its graphical-session
      # target.
      exec waybar
    '';
  };
}
