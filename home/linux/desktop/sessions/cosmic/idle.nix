_: {
  # LifeSaver is the deliberate fullscreen idle display. Disable COSMIC's
  # automatic screen-off and suspend actions on both AC and battery so it is
  # never hidden behind a blank or sleeping session.
  wayland.desktopManager.cosmic.idle = {
    screen_off_time = {
      __type = "optional";
      value = null;
    };
    suspend_on_ac_time = {
      __type = "optional";
      value = null;
    };
    suspend_on_battery_time = {
      __type = "optional";
      value = null;
    };
  };
}
