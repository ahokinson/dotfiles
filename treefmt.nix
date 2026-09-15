# `nix fmt` rewrites the tree; `nix flake check` fails if it is not already
# formatted.
#
# Nix-only: the markdown files under home/common are prompt documents, and
# the vendored SVGs and wallpaper JPGs under home/common/_files can't be nix
# (a few feed derivations by path, the rest are binary). A formatter would
# fight both.
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
    "*.md"
    ".gitignore"
    "flake.lock"
    "home/common/_files/*"
  ];
}
