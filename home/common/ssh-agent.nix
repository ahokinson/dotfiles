# One agent so SSH_AUTH_SOCK is always set. Keys are added by hand.
_: {
  services.ssh-agent.enable = true;
}
