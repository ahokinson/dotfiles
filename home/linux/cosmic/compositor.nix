# Trackpad "feel" toward macOS's, for the same reason the rest of this
# migration chases visual/behavioral parity — NixOS only, framework13-only.
# Mapped from modules/darwin/system.nix's system.defaults.trackpad.* block
# (this repo's actual real-machine values, not macOS's stock defaults —
# e.g. natural scrolling is OFF here, not on) onto COSMIC's compositor
# input config (wayland.desktopManager.cosmic.compositor.input_touchpad).
#
# The two systems' trackpad models don't map 1:1 (macOS's AppleTrackpad
# prefs vs. libinput's click_method/tap_config/scroll_config), so this is
# an approximation of intent, not a literal value-for-value port:
# - Clicking = false (tap-to-click off on macOS) -> tap_config.enabled = false
# - TrackpadRightClick = true + enableSecondaryClick = true (two-finger
#   right-click) -> click_method = Clickfinger (button determined by finger
#   count, not screen zone - ButtonAreas is the corner-click model macOS
#   doesn't use)
# - Dragging = false, TrackpadThreeFingerDrag = false -> tap_config.drag/
#   drag_lock = false
# - com.apple.swipescrolldirection = false (natural scrolling off on this
#   machine specifically) -> scroll_config.natural_scroll = false
#
# tap_config and scroll_config are submodules whose own fields (button_map;
# method/scroll_button/scroll_factor) have no default in cosmic-manager -
# once either submodule is set at all, every field in it is mandatory. The
# ones below with no darwin equivalent are left at libinput's own
# conventional values (as shown in cosmic-manager's own option defaults),
# not a macOS mapping: button_map, scroll method (TwoFinger - the standard
# modern-touchpad scroll gesture, independent of natural_scroll's
# direction), scroll_button, scroll_factor.
{ ... }: {
  wayland.desktopManager.cosmic.compositor.input_touchpad = {
    click_method = {
      __type = "optional";
      value = { __type = "enum"; variant = "Clickfinger"; };
    };

    tap_config = {
      __type = "optional";
      value = {
        enabled = false;
        drag = false;
        drag_lock = false;
        button_map = {
          __type = "optional";
          value = { __type = "enum"; variant = "LeftMiddleRight"; };
        };
      };
    };

    scroll_config = {
      __type = "optional";
      value = {
        method = {
          __type = "optional";
          value = { __type = "enum"; variant = "TwoFinger"; };
        };
        natural_scroll = { __type = "optional"; value = false; };
        scroll_button = { __type = "optional"; value = 2; };
        scroll_factor = { __type = "optional"; value = 1.0; };
      };
    };
  };
}
