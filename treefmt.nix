# `nix fmt` rewrites the tree; `nix flake check` fails if it is not already
# formatted.
#
# Nix-only: the markdown, JSON, JS and theme files under home/common are
# vendored assets and prompt documents, and
# home/common/claude/_files/settings.json is an out-of-store symlink Claude
# Code rewrites at runtime. A formatter would fight both.
_: {
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true; # RFC 166 style
  programs.deadnix.enable = true;

  # statix writes its own statix.toml into the store and passes --config, so
  # one at the repo root is ignored; lints are disabled here instead.
  # `statix list` names them.
  programs.statix = {
    enable = true;
    disabled-lints = [ ];
  };

  # nixos-generate-config output, reproduced verbatim on a reinstall, so
  # deadnix must not strip the arguments it declares but never uses.
  settings.formatter.deadnix.excludes = [ "hosts/*/hardware-configuration.nix" ];

  settings.global.excludes = [
    "*.conf"
    "*.css"
    "*.js"
    "*.json"
    "*.jsonc"
    "*.md"
    "*.png"
    "*.svg"
    "*.theme"
    "*.tmTheme"
    "*.ts"
    "*.yaml"
    "*.yml"
    "*.zsh"
    ".gitignore"
    "flake.lock"
    "home/common/_files/*"
    "home/common/yt-dlp/config"
    "home/darwin/_files/*"
  ];
}
