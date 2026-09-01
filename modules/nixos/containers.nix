# The Linux-native counterpart to `podman machine` on the Darwin hosts
# (home/darwin/podman.nix).
_: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
