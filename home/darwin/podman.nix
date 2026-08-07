# podman on macOS runs containers inside a VM (unlike NixOS's native
# rootless runtime, see modules/nixos/containers.nix), which needs a
# one-time `podman machine init` + `start`. nix-darwin's system activation
# can't do this - it runs as root, and the VM is per-user state - so this
# runs as a home-manager activation hook instead (same constraint as
# wallpaper.nix). Idempotent: checks state before acting, so re-running
# `darwin-rebuild switch` never re-inits or re-starts an already-running
# machine.
{ pkgs, lib, ... }:
{
  home.activation.podmanMachine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.podman}/bin:$PATH"
    if ! podman machine inspect podman-machine-default &>/dev/null; then
      run podman machine init
    fi
    if [[ "$(podman machine inspect podman-machine-default --format '{{.State}}' 2>/dev/null)" != "running" ]]; then
      run podman machine start
    fi
  '';
}
