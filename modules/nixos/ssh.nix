_: {
  services.openssh = {
    enable = true;
    settings = {
      # Key-only. authorized_keys is managed by hand, not by this repo.
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
