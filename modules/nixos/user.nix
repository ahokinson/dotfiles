{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.users."anders" = {
    isNormalUser = true;
    description = "Anders";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}