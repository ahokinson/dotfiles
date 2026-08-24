{ pkgs, username, ... }: {
  programs.zsh.enable = true;

  # User account. Default shell is nixpkgs-managed zsh, overriding the stock
  # macOS zsh so it tracks nixpkgs.
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
