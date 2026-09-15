{ pkgs, ... }:
with pkgs;
[
  clipleaks
  gitleaks
  gosec
  kubescape
  nuclei
  prowler
  semgrep
  testssl
]
