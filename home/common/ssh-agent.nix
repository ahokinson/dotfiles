# Keys are added by hand (ssh-add); this just keeps an agent running so
# SSH_AUTH_SOCK is always set, instead of starting one ad hoc per shell.
_: {
  services.ssh-agent.enable = true;
}
