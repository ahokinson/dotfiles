{ pkgs, ... }:
with pkgs;
[
  bun
  cargo
  clippy
  go
  nodejs
  python3
  rust-analyzer
  rustc
  rustfmt
  zig
]
