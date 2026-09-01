# Home-manager wiring for NixOS hosts. Counterpart to
# modules/darwin/home-manager.nix, and identical in intent: the userland
# (dotfiles, shell, packages, COSMIC) is the same on every Linux box, so only
# system-level concerns - hostname, hardware - differ per host.
{
  inputs,
  selfPath,
  username,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # First activation on a machine still running the old ~/.dotfiles
    # symlink-based setup will collide on real pre-existing files
    # (.zshrc, .gitconfig, etc). Back those up with this suffix instead of
    # hard-failing.
    backupFileExtension = "hm-backup";
    users.${username} = {
      imports = [
        (selfPath "home/common")
        (selfPath "home/linux")
        (selfPath "home/linux/cosmic")
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.zen-browser.homeModules.beta
      ];
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
    };
    # username included to match modules/darwin/home-manager.nix; nothing
    # under home/ reads it yet, but the two platforms handing their home
    # modules a different argument set is the kind of difference that only
    # ever gets noticed the hard way.
    extraSpecialArgs = { inherit inputs selfPath username; };
  };
}
