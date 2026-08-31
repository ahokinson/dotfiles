{ pkgs, ... }: {
  # CUPS + brlaser for the Brother laser (toner) printer, plus Avahi/mDNS so
  # network printers get discovered automatically instead of needing a
  # manual IP-based setup. No GUI frontend: the queue discovers itself, and
  # localhost:631 covers the rare manual change.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];

    # Defaults on whenever Avahi is enabled, and re-adds the already-discovered
    # printer as a duplicate implicitclass:// queue beside the real ipp:// one.
    browsed.enable = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
