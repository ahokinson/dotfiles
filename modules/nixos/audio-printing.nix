{ pkgs, ... }: {
  # CUPS + brlaser for the Brother laser (toner) printer, plus Avahi/mDNS so
  # network printers get discovered automatically instead of needing a
  # manual IP-based setup.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    system-config-printer
  ];

  # PipeWire audio stack
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
