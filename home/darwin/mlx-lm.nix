# macstudio-m1-max only. nixpkgs' mlx/mlx-lm build with Metal disabled
# (Apple's Metal compiler isn't open-source), so this installs from
# upstream's own PyPI wheels via uv instead.
{
  pkgs,
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.networking.hostName == "macstudio-m1-max") {
  home.activation.mlxLm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath [ pkgs.uv ]}:$PATH"
    run uv tool install --upgrade mlx-lm
  '';
}
