# Raspberry Pi 4, DNS ad-blocker appliance. Only what this host is for; the
# rest is in hosts/raspberrypi-common.nix.
# First install: see README's "First activation on a new Raspberry Pi".
# After that: rsync this repo to the box and run
# `sudo nixos-rebuild switch --flake .#pi-hole` there directly - root login
# is disabled (modules/nixos/ssh.nix) and anders isn't a trusted Nix user,
# so a `--target-host` build-elsewhere-and-copy deploy fails with an
# untrusted-signature error. Building locally sidesteps that entirely.
{ config, selfPath, ... }:
{
  networking.hostName = "pi-hole";

  imports = [ (selfPath "hosts/raspberrypi-common.nix") ];

  # No disko here - see raspberrypi-common.nix's fileSystems comment for why.

  # nixpkgs has no native services.pihole module; the official image is the
  # supported path. modules/nixos/containers.nix (imported via
  # raspberrypi-common.nix) already gives this host a podman-backed
  # dockerCompat socket, so this just points oci-containers at it rather
  # than pulling in a second container runtime. The container is named
  # "pihole" (the software), independent of the host's own name.
  # Podman, unlike Docker, refuses to auto-create a missing bind-mount
  # source directory on the host - it just fails the container start with
  # "statfs: no such file or directory". These have to exist before the
  # service ever runs.
  systemd.tmpfiles.rules = [
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
  ];

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.pihole = {
    # Pin to a specific stable tag, never :latest, so a bump stays a
    # reviewable one-line edit - same reasoning as this repo's own tools.
    # Current as of github.com/pi-hole/docker-pi-hole/releases at
    # implementation time; re-check there before bumping.
    image = "docker.io/pihole/pihole:2026.07.2";
    environment = {
      TZ = config.time.timeZone;
    };
    volumes = [
      "/var/lib/pihole/etc-pihole:/etc/pihole"
      "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    # Host networking, not the default bridge + port mappings: podman's own
    # embedded resolver (aardvark-dns, from modules/nixos/containers.nix's
    # dns_enabled=true, shared by every host in the fleet) also wants port
    # 53 on the bridge gateway, and a container that itself wants port 53
    # collides with it - "failed to bind udp listener on 10.88.0.1:53:
    # Address already in use". Host networking sidesteps that entirely, and
    # as a bonus pi-hole sees clients' real LAN IPs for its per-client
    # stats instead of the bridge's NAT address. No `ports` needed - the
    # container's ports are the host's ports now.
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--network=host"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    53
    80
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # The admin password: set by hand after first boot, never generated or
  # stored by Nix - same line ssh.nix draws for authorized_keys.
  #   podman exec -it pihole pihole setpassword
}
