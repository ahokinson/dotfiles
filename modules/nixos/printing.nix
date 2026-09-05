{
  lib,
  pkgs,
  selfPath,
  ...
}:
{
  imports = [ (selfPath "modules/nixos/mdns.nix") ];

  # No GUI frontend; localhost:631 covers the rare manual change.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];

    # Defaults on with Avahi, and re-adds the printer below as a duplicate
    # implicitclass:// queue beside the real ipp:// one.
    browsed.enable = false;

    # cups.out lands in environment.systemPackages regardless of a GUI
    # frontend, carrying share/applications/cups.desktop with it. COSMIC's
    # app library doesn't prefer home/linux/applications.nix's NoDisplay
    # override over this copy the way XDG_DATA_DIRS order says it should, so
    # the entry has to not exist here at all.
    package = pkgs.cups.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -f $out/share/applications/cups.desktop
      '';
    });
  };

  # Declared rather than discovered so it survives a reinstall.
  # ensureDefaultPrinter is a no-op unless ensurePrinters is set.
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

  # The printer and this laptop's network are rarely both up when a switch
  # runs, and switch-to-configuration fails the whole switch on ANY unit
  # that's currently failed, system-wide - not just ones it touched. A
  # retry can't dodge that check, so this can never be allowed to fail:
  #   - RemainAfterExit off so it's never "already done" and skipped; every
  #     switch gets a fresh, free attempt instead of one shot forever.
  #   - set +e / exit 0 wraps the module's own script so an unreachable
  #     printer can't turn into a failed unit.
  systemd.services.ensure-printers = {
    serviceConfig.RemainAfterExit = lib.mkForce false;
    script = lib.mkMerge [
      (lib.mkBefore "set +e\n")
      (lib.mkAfter "\nexit 0\n")
    ];
  };
}
