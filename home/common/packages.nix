{ pkgs, lib, selfPath, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  # macOS installs the fonts system-wide via fonts.packages
  # (modules/darwin/system.nix), and fontconfig is inert for native macOS apps,
  # so the home-level install/fontconfig is Linux-only to avoid duplicating them.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.packages = with pkgs; lib.flatten [
    acli
    awscli2
    btop
    bun
    cargo
    clipleaks
    clippy
    cmake
    codex
    colima
    cosign
    crane
    delta
    delve
    dive
    dust
    f3
    fd
    ffmpeg
    fish
    fzf
    gcc
    gh
    gitleaks
    glab
    go
    go-task
    golangci-lint
    gosec
    grype
    hadolint
    httpie
    hyperfine
    inetutils
    jq
    k9s
    kubernetes-helm
    kubescape
    lazydocker
    lazygit
    mediainfo
    (lib.optionals (!isDarwin) sharedFonts.packages)
    nmap
    nodejs
    nuclei
    ollama
    onefetch
    open-policy-agent
    osv-scanner
    pandoc
    pkg-config
    portaudio
    procs
    prowler
    pv
    ripgrep
    ruff
    rust-analyzer
    rustc
    rustfmt
    scorecard
    semgrep
    sox
    sqld
    stylua
    syft
    terraform
    testssl
    texliveBasic
    trivy
    trufflehog
    turso-cli
    twitch-cli
    uv
    yq-go
    zig
  ];

  fonts.fontconfig.enable = lib.mkIf (!isDarwin) true;
}
