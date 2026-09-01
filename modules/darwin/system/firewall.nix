_: {
  # blockAllIncoming stays false: true also blocks AirDrop and sharing.
  # Stealth mode still drops unsolicited probes.
  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = false;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };

  services.openssh.enable = false;
}
