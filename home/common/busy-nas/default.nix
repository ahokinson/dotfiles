{
  config,
  username,
  pkgs,
  inputs,
  ...
}:
{
  # No overlays.default of its own (see overlays/default.nix's comment), so
  # reached directly here rather than through pkgs.busy-nas.
  home.packages = [ inputs.busy-nas.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  xdg.configFile."busy-nas/config.toml".text = ''
    # Local, temporary worktrees. This must be a local directory, not the NAS mount.
    workspace_root = "${config.home.homeDirectory}/Local/Developer"
    snapshot_retention = 20

    [nas]
    host = "pi-nas.home.arpa"
    user = "${username}"
    root = "/srv/developer"
  '';
}
