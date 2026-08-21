{ ... }: {
  networking.networkmanager.enable = true;
  # MT7925 power save causes intermittent drops on suspend/resume.
  networking.networkmanager.wifi.powersave = false;
}