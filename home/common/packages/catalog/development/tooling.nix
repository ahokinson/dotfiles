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
  texliveBasic
  turso-cli
  uv
]
