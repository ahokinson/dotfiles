{ pkgs, username, ... }: {
  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Anders";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
