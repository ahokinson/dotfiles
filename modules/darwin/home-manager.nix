# Home-manager wiring for darwin hosts.
# The userland (dotfiles, shell, packages) is identical across all macs.
# Only system-level concerns (hostname, hardware) differ, handled per-host
# in flake.nix.
{ inputs, selfPath, ... }: {
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # First activation on a machine still running the old ~/.dotfiles
    # symlink-based setup will collide on real pre-existing files
    # (.zshrc, .gitconfig, etc). Back those up with this suffix instead of
    # hard-failing.
    backupFileExtension = "hm-backup";
    users."anders" = {
      imports = [
        inputs.zen-browser.homeModules.beta
        (selfPath "home/common")
        (selfPath "home/darwin")
      ];
      home.username = "anders";
      home.homeDirectory = "/Users/anders";
      home.stateVersion = "26.05";
    };
    extraSpecialArgs = { inherit inputs selfPath; };
  };
}
