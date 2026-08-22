{ pkgs, ... }: {
  programs.zsh.enable = true;

  # User account (matches ahokinson/dotfiles /Users/anders). Default shell is
  # nixpkgs-managed zsh, overriding the stock macOS zsh so it tracks nixpkgs.
  users.users."anders" = {
    name = "anders";
    home = "/Users/anders";
    shell = pkgs.zsh;
  };
}
