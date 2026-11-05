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
      booktabs
      enumitem
      microtype
      pdfcol
      tcolorbox
      tikzfill
      titlesec
      ;
  })
  turso-cli
  uv
]
