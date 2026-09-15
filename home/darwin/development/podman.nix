# Containers run in a VM here, which needs a one-time `podman machine init`
# and `start`. A home-manager hook because the VM is per-user state and
# nix-darwin's activation runs as root. Idempotent: state is checked first,
# so a repeat switch never re-inits or restarts a running machine.
{ pkgs, lib, ... }:
{
  home.activation.podmanMachine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # home-manager's activation PATH has no /usr/bin, so `podman machine
    # init` cannot find the ssh-keygen it shells out to for the VM keypair
    # and fails with `exec: "ssh-keygen": executable file not found in $PATH`.
    # Only ever seen on activation, never in an interactive shell. vfkit and
    # gvproxy need no help; the nixpkgs podman wrapper already carries them.
    export PATH="${
      lib.makeBinPath [
        pkgs.podman
        pkgs.openssh
      ]
    }:$PATH"
    if ! podman machine inspect podman-machine-default &>/dev/null; then
      run podman machine init
    fi
    if [[ "$(podman machine inspect podman-machine-default --format '{{.State}}' 2>/dev/null)" != "running" ]]; then
      run podman machine start
    fi
  '';
}
