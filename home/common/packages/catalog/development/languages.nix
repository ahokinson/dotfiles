{ pkgs, ... }:
with pkgs;
[
  bun
  cargo
  clippy
  go
  nodejs
  pnpm
  python3
  rust-analyzer
  rustc
  rustfmt
  zig
]
