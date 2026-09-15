{ pkgs, ... }:
with pkgs;
[
  cosign
  grype
  open-policy-agent
  osv-scanner
  scorecard
  syft
  tirith
  trivy
  trufflehog
]
