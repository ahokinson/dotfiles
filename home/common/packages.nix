# Aggregate user packages across all hosts — replaces the upstream Brewfile.* set as much as possible.
# Items not in nixpkgs (rancher desktop, leader-key, basictex, twitch-cli, turso, acli,
# claude-code, bloom, cupcake, tirith) are intentionally omitted here. Until respective
# Nix flake inputs are wired, install them manually per-host or wire a flake input.
#
# Layout follows the upstream Brewfile.* categorisation for ease of comparison.
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; lib.flatten [
    # Brewfile.ai
    ollama

    # Brewfile.build
    cmake
    go-task
    pkg-config

    # Brewfile.cli
    awscli2
    bat
    btop
    dust
    fd
    gh
    glab
    httpie
    hyperfine
    jq
    onefetch
    procs
    pv
    yq-go

    # Brewfile.container
    crane
    dive
    k9s
    lazydocker

    # Brewfile.debugging
    delve

    # Brewfile.document
    pandoc

    # Brewfile.editor (lazygit/neovim/git-delta/fzf/ripgrep here; nvim module also pulls some)
    lazygit
    delta
    ripgrep

    # Brewfile.infrastructure
    terraform
    kubernetes-helm   # the `helm` binary
    # turso — needs flake/manual install

    # Brewfile.language
    bun
    go
    uv
    zig
    # rust — install via `rustup` or wire `rustToolchain`/`fenix` separately

    # Brewfile.media (yt-dlp comes from the yt-dlp home module)
    ffmpeg
    mediainfo
    sox

    # Brewfile.quality
    golangci-lint
    gosec
    stylua
    ruff

    # Brewfile.security
    syft
    # checkov — currently fails to build on x86_64-linux via pycep-parser;
    # install manually until upstream is fixed
    cosign
    f3                    # flash-storage tester
    gitleaks
    grype
    hadolint
    kubescape
    nmap
    nuclei
    open-policy-agent     # `opa` binary — powers cupcake policies
    osv-scanner
    # prowler, scorecard — possibly missing in nixpkgs; wire later if needed
    semgrep
    testssl
    trivy
    trufflehog
    # mitmproxy — currently fails to build due to msgpack runtime dep mismatch
    # (msgpack<=1.1.2 vs 1.2.1). Re-add once nixpkgs resolves the conflict.

    # Brewfile.terminal — Nerd Fonts (new nixpkgs split packages)
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Fonts for GUI apps — nixpkgs `nerdfonts` is a font set; expose via `fonts.fontconfig.enable = true`
  fonts.fontconfig.enable = true;
}