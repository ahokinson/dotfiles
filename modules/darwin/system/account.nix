{ pkgs, username, ... }: {
  programs.zsh.enable = true;

  # nixpkgs zsh as the login shell, not the stock macOS one.
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
