# Work Mac only. Podman machine's remote client talks to a service running
# inside its Linux VM, which is what actually does registry auth - so a
# credHelpers binary installed on the macOS host (see cloud.nix) never gets
# exercised. Docker's CLI resolves credHelpers itself, host-side, before
# talking to colima's VM, so the same credential helper actually works here.
{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.colima
    # Client-only on Darwin; bundles the buildx/compose plugins already.
    pkgs.docker
    # config.json's credsStore falls back to osxkeychain for anything
    # outside credHelpers' registries (e.g. Docker Hub); Rancher Desktop
    # used to be what provided that binary on PATH.
    pkgs.docker-credential-helpers
  ];

  home.activation = {
    colima = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # home-manager's activation PATH has no /usr/bin, so colima cannot find
      # the ssh-keygen it shells out to for the VM keypair (same issue podman
      # machine hits in podman.nix) or sw_vers, which it uses to pick a VM
      # driver. ssh-keygen comes from nixpkgs; sw_vers is Apple's own binary,
      # so /usr/bin is appended as a fallback rather than pulled in first.
      export PATH="${
        lib.makeBinPath [
          pkgs.colima
          pkgs.docker
          pkgs.openssh
        ]
      }:$PATH:/usr/bin"
      if ! colima status &>/dev/null; then
        # On a truly fresh VM, colima adds the user to the guest's docker
        # group, then checks `docker info` works without sudo; if the still
        # -open SSH session hasn't picked up the new group membership yet,
        # colima tries to restart the guest to refresh it, but that restart
        # path runs against an uninitialized VM handle and dies with
        # `cannot restart, VM not previously started`. By the second
        # attempt the VM already exists and the group membership is
        # already live, so it starts clean.
        run colima start || run colima start
      fi
    '';

    # Registry hostnames aren't committed here (an AWS account ID is
    # exposure this repo's public GitHub mirror doesn't need) - they live in
    # ~/.reggora/ecr-registries, one per line, read at activation time.
    dockerEcrAuth = lib.hm.dag.entryAfter [ "colima" ] ''
      registriesFile="$HOME/.reggora/ecr-registries"
      authFile="$HOME/.docker/config.json"
      if [[ -f "$registriesFile" ]]; then
        run mkdir -p "$(dirname "$authFile")"
        [[ -f "$authFile" ]] || echo '{}' > "$authFile"
        while IFS= read -r registry; do
          [[ -z "$registry" ]] && continue
          tmp="$authFile.ecr-tmp"
          ${pkgs.jq}/bin/jq --arg registry "$registry" \
            '.credHelpers[$registry] = "ecr-login"' \
            "$authFile" > "$tmp" && mv "$tmp" "$authFile"
        done < "$registriesFile"
      fi
    '';
  };
}
