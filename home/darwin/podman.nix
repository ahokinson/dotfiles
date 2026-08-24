# podman on macOS runs containers inside a VM (unlike NixOS's native
# rootless runtime), which needs a
# one-time `podman machine init` + `start`. nix-darwin's system activation
# can't do this - it runs as root, and the VM is per-user state - so this
# runs as a home-manager activation hook instead (same constraint as
# wallpaper.nix). Idempotent: checks state before acting, so re-running
# `darwin-rebuild switch` never re-inits or re-starts an already-running
# machine.
{ pkgs, lib, ... }:
{
  home.activation.podmanMachine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # home-manager's activation PATH is hermetic - bash, coreutils and a
    # handful of others, no /usr/bin - so `podman machine init` cannot find
    # the system ssh-keygen it shells out to for the VM's keypair, and fails
    # with `exec: "ssh-keygen": executable file not found in $PATH`. Interactive
    # shells never hit this, which is why it only shows up on activation.
    # vfkit and gvproxy need no such help: nixpkgs' podman wrapper already
    # bakes vfkit into its PATH and ships gvproxy in libexec.
    export PATH="${lib.makeBinPath [ pkgs.podman pkgs.openssh ]}:$PATH"
    if ! podman machine inspect podman-machine-default &>/dev/null; then
      run podman machine init
    fi
    if [[ "$(podman machine inspect podman-machine-default --format '{{.State}}' 2>/dev/null)" != "running" ]]; then
      run podman machine start
    fi
  '';
}
