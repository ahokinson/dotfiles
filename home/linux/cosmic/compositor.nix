# Trackpad "feel" toward macOS's, mapped from modules/darwin/system's
# trackpad.* block (this repo's actual real-machine values, not macOS's
# stock defaults - e.g. natural scrolling is off here) onto COSMIC's
# compositor input config. Shared by every COSMIC host; harmlessly unused on
# studio-m1-max, which has no built-in trackpad.
#
# The two systems' trackpad models don't map 1:1 (macOS's AppleTrackpad
# prefs vs. libinput's click_method/tap_config/scroll_config), so this is an
# approximation of intent: tap-to-click off -> tap_config.enabled = false;
# two-finger right-click -> click_method = Clickfinger; natural scrolling
# off -> scroll_config.natural_scroll = false. Fields with no darwin
# equivalent (button_map, scroll method/button/factor) are left at
# libinput's own conventional values.
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
