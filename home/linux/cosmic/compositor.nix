# Trackpad feel mapped from modules/darwin/system's trackpad.* block, which
# holds this repo's real values rather than macOS's stock ones. Unused on
# studio-m1-max, which has no trackpad.
#
# AppleTrackpad prefs and libinput's click_method/tap_config/scroll_config do
# not map 1:1, so this approximates: tap-to-click off -> tap_config.enabled
# false; two-finger right-click -> click_method Clickfinger; natural scrolling
# off -> scroll_config.natural_scroll false. button_map and the scroll
# method/button/factor fields have no darwin equivalent and stay at libinput's
# values.
{ selfPath, ... }:
let
  inherit (import (selfPath "home/linux/cosmic/ron.nix")) ronOptional ronEnum;
in
{
  wayland.desktopManager.cosmic.compositor.input_touchpad = {
    click_method = ronOptional (ronEnum "Clickfinger");

    tap_config = ronOptional {
      enabled = false;
      drag = false;
      drag_lock = false;
      button_map = ronOptional (ronEnum "LeftMiddleRight");
    };

    scroll_config = ronOptional {
      method = ronOptional (ronEnum "TwoFinger");
      natural_scroll = ronOptional false;
      scroll_button = ronOptional 2;
      scroll_factor = ronOptional 1.0;
    };
  };
}
