# macOS GUI apps nixpkgs can't build (or can't build cleanly) — managed via
# Brew casks under nix-darwin. Casks are deterministic under nix-darwin:
# `darwin-rebuild switch` runs `brew bundle` against this list each time.
{ ... }: {
  # ghostty GUI on darwin is installed via the brew cask; the ghostty home-manager
# module (home/common/ghostty) still writes the config + theme files and sets
# `programs.ghostty.package = null` so we don't double-install the nixpkgs one.
  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation = {
      cleanup = "uninstall";   # remove casks not declared here
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "ghostty"
    ];
  };
}