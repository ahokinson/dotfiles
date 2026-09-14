# programs.chromium here is nixpkgs' own NixOS module
# (nixos/modules/programs/chromium.nix) - writes
# /etc/chromium/policies/managed/extra.json from extraOpts. The package
# itself comes from home/common/chromium (home-manager).
{ selfPath, ... }:
{
  programs.chromium = {
    enable = true;
    extraOpts = import (selfPath "home/common/chromium/policy.nix");
  };
}
