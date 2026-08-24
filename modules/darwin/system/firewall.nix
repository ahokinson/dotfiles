{ ... }: {
  # blockAllIncoming stays false: true would also kill AirDrop/sharing.
  # Stealth mode still keeps the machine from responding to unsolicited
  # probes. Signed software is let through automatically.
  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = false;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };

  # Not managed via services.openssh elsewhere on darwin, so this is
  # authoritative for it.
  services.openssh.enable = false;
}
