{ ... }: {
  services.openssh = {
    enable = true;
    settings = {
      # Key-only - relies on an authorized_keys already present for anders
      # (managed imperatively, not through this repo).
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
