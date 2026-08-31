{ pkgs, ... }: {
  # CUPS + brlaser for the Brother laser (toner) printer, plus Avahi/mDNS so
  # network printers resolve by name instead of needing a manual IP-based
  # setup. No GUI frontend: localhost:631 covers the rare manual change.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];

    # Defaults on whenever Avahi is enabled, and re-adds the declared printer
    # as a duplicate implicitclass:// queue beside the real ipp:// one.
    browsed.enable = false;
  };

  # The queue is declared rather than left to discovery so it survives a
  # reinstall. ensureDefaultPrinter is a no-op unless ensurePrinters is set.
  hardware.printers = {
    ensureDefaultPrinter = "Brother_MFC-L2710DW_series";
    ensurePrinters = [
      {
        name = "Brother_MFC-L2710DW_series";
        description = "Brother MFC-L2710DW series";
        deviceUri = "ipp://BRW5C6199625692.local:631/ipp/print";
        # Driverless IPP Everywhere; brlaser stays for a USB fallback.
        model = "everywhere";
      }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
