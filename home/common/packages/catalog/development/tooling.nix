{ pkgs, ... }:
with pkgs;
[
  cmake
  crane
  delve
  gcc
  golangci-lint
  hadolint
  pkg-config
  ruff
  stylua
  terraform
  (texlive.combine {
    inherit (texlive)
      scheme-basic
      xcolor
      pgf
      fontspec
      ;
  })
  turso-cli
  uv
]
