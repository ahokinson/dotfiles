# Rootless Podman with Docker-CLI compatibility, so the shared `podman`
# package (home/common/packages.nix) plus lazydocker/dive have a runtime to
# talk to on Linux, matching `podman machine` on the Darwin hosts.
_: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
