{
  inputs,
  selfPath,
  config,
  username,
  ...
}:
let
  hostFacts = import (selfPath "home/common/lib/host.nix") { osConfig = config; };
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    (selfPath "modules/shared/nix/home-manager.nix")
  ];

  home-manager = {
    sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    users.${username}.imports = [
      inputs.zen-browser.homeModules.beta
      (selfPath "home/common")
      (selfPath "home/darwin")
    ];
    extraSpecialArgs = {
      inherit
        inputs
        selfPath
        username
        hostFacts
        ;
    };
  };
}
