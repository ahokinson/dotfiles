# Home-manager wiring for darwin hosts.
# The userland (dotfiles, shell, packages) is identical across all macs —
# only system-level concerns (hostname, hardware) differ, handled per-host
# in flake.nix via the mkDarwin factory.
{ inputs, ... }: {
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."anders" = {
      imports = [
        ../../home/common
        ../../home/darwin
      ];
      home.username = "anders";
      home.homeDirectory = "/Users/anders";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs; };
  };
}