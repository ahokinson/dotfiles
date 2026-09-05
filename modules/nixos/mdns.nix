# services.avahi's mDNS responder, identical wherever it's needed: shared by
# printing.nix (Bonjour print-sharing discovery) and the headless Pi hosts
# (so their installer/real hostnames resolve as *.local over SSH).
_: {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
