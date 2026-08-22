# Returns the right nix tool + args for the requested mode on a given output.
build_args() {
  local mode=$1 output=$2 kind=$3

  local darwin_subcmd
  case $mode in
    switch) darwin_subcmd=switch ;;
    build)  darwin_subcmd=build ;;
    dry)    darwin_subcmd=check ;;
  esac

  case $kind:$mode in
    darwin:switch|darwin:build|darwin:dry)
      if command -v darwin-rebuild &>/dev/null; then
        print sudo darwin-rebuild "$darwin_subcmd" --flake "$DOTFILES#$output"
      else
        # First-ever activation: darwin-rebuild isn't installed yet, and
        # root's own Nix config won't have flakes enabled until after a
        # successful activation writes it system-wide - bootstrap through
        # `nix run nix-darwin` with the flags passed explicitly instead.
        print "sudo nix --extra-experimental-features \"nix-command flakes\" run nix-darwin -- $darwin_subcmd --flake \"$DOTFILES#$output\""
      fi
      ;;
    darwin:list)   return 0 ;;
    nixos:switch)  print sudo nixos-rebuild switch --flake "$DOTFILES#$output" ;;
    nixos:build)   print nixos-rebuild build      --flake "$DOTFILES#$output" ;;
    nixos:dry)     print nixos-rebuild dry-build  --flake "$DOTFILES#$output" ;;
    nixos:list)    return 0 ;;
    # -b backs up colliding unmanaged files instead of aborting activation -
    # the standalone equivalent of home.backupFileExtension, which isn't
    # valid outside a nix-darwin/NixOS-integrated homeManagerConfiguration.
    #
    # experimental-features goes via NIX_CONFIG, not a CLI flag: a brand-new
    # Asahi install's stock Nix has flakes/nix-command disabled until this
    # very command enables them, and `nix run home-manager -- switch` shells
    # out to further `nix` invocations that only inherit environment, not
    # CLI flags.
    home:switch)   print "NIX_CONFIG=\"experimental-features = nix-command flakes\" nix run $HOME_MANAGER_TOOL -- switch -b hm-backup --flake \"$DOTFILES#$output\"" ;;
    home:build)    print "NIX_CONFIG=\"experimental-features = nix-command flakes\" nix build \"$DOTFILES#homeConfigurations.\\\"$output\\\".activationPackage\"" ;;
    home:dry)      print "NIX_CONFIG=\"experimental-features = nix-command flakes\" nix run $HOME_MANAGER_TOOL -- build --flake \"$DOTFILES#$output\"" ;;
    home:list)     return 0 ;;
    *) return 1 ;;
  esac
}
