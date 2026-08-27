# treefmt-nix config, consumed by the `formatter` and `checks` outputs in
# flake.nix: `nix fmt` rewrites the tree, `nix flake check` fails if the tree
# is not already formatted.
#
# Nix-only on purpose. The markdown, JSON, JS and theme files under
# home/common are vendored upstream assets and prompt documents, and
# home/common/claude/_files/settings.json is an out-of-store symlink that
# Claude Code rewrites at runtime - a formatter would fight both.
{ ... }: {
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true; # RFC 166 style
  programs.deadnix.enable = true;

  # statix generates its own statix.toml into the store and passes it with
  # --config, so a statix.toml at the repo root would be ignored; lints are
  # turned off here instead. `statix list` names them - `empty_pattern`
  # (rewrites `{ ... }: {` to `_: {`) is the likely first candidate.
  programs.statix = {
    enable = true;
    disabled-lints = [ ];
  };

  # nixos-generate-config output, reproduced verbatim on a reinstall, so
  # deadnix must not strip the arguments it declares but does not use.
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
