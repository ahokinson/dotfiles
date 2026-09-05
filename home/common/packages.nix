{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
  # macOS installs the fonts system-wide (modules/darwin/system) and ignores
  # fontconfig, so the home-level install is Linux-only.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.packages =
    with pkgs;
    lib.flatten [
      acli
      awscli2
      # Reads per-connection data off raw sockets, so it needs root: run it
      # via sudo. Nothing else in this repo gets a wrapper/capability
      # treatment, so none is invented here.
      bandwhich
      bun
      cargo
      clipleaks
      clippy
      cmake
      cosign
      crane
      delta
      delve
      dive
      duf
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
      golangci-lint
      gosec
      grype
      hadolint
      httpie
      hyperfine
      inetutils
      jq
      killall
      kubernetes-helm
      kubescape
      mediainfo
      moreutils
      (lib.optionals (!isDarwin) sharedFonts.packages)
      ncdu
      # nh itself comes from programs.nh (home/common/nh.nix).
      nix-diff
      nix-melt
      nix-output-monitor
      nix-tree
      nmap
      nodejs
      nuclei
      nurl
      nvd
      ollama
      onefetch
      open-policy-agent
      osv-scanner
      pandoc
      pkg-config
      # The macOS VM is set up in home/darwin/podman.nix; NixOS runs it
      # natively and rootless.
      podman
      portaudio
      posting
      procs
      proton-vpn
      prowler
      psyche
      pv
      python3
      qpdf
      reliquary
      ripgrep
      rsync
      ruff
      rust-analyzer
      rustc
      rustfmt
      scorecard
      sd
      semgrep
      signal-desktop
      # Linux gets slack (or slacky on Asahi) from home/linux/packages.nix;
      # pkgs.slack has no aarch64-linux build.
      (lib.optionals isDarwin [ slack ])
      sox
      sqld
      stylua
      syft
      terraform
      testssl
      texliveBasic
      tirith
      tree
      trivy
      trufflehog
      turso-cli
      twitch-cli
      unzip
      uv
      # No vesktop: programs.vesktop installs its own, and a second copy
      # collides in the profile.
      yq-go
      zig
    ];

  fonts.fontconfig.enable = lib.mkIf (!isDarwin) true;
}
