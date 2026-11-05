# Manual/float-first tiling: windows float by default, bsp is opt-in per
# space via a skhd hotkey (see home/darwin/apps/desktop/lifesaver.nix for the
# keybindings). enableScriptingAddition stays off deliberately — it needs SIP
# partially disabled, and nix-darwin's SA loader re-signs against a fresh
# /nix/store path on every rebuild, which is a known way to crash-loop
# Dock.app (nix-darwin#750). Everything here (focus/swap/resize/grid/layout)
# works fine under plain Accessibility permission without it.
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;

    config = {
      layout = "float";
      window_placement = "second_child";
      window_opacity = "off";
      window_shadow = "on";
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 12;
    };

    extraConfig = ''
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add app="^Software Update$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add title="^(Preferences|Settings)$" manage=off
    '';
  };
}
