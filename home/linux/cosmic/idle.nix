_: {
  # Screen blanking stays at cosmic-manager's default (screen_off_time,
  # left unset here) - only the suspend triggers are disabled, so the
  # system itself never sleeps on idle, on AC or battery.
  wayland.desktopManager.cosmic.idle = {
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
