{
  pkgs,
  username,
  selfPath,
  ...
}:
{
  imports = [ (selfPath "modules/shared/nix/shell.nix") ];

  # nixpkgs zsh as the login shell, not the stock macOS one.
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
