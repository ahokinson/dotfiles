{
  pkgs,
  username,
  selfPath,
  ...
}:
{
  imports = [ (selfPath "modules/shared/nix/shell.nix") ];

  users.users.${username} = {
    isNormalUser = true;
    description = "Anders";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
