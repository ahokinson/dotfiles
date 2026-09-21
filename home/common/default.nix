{
  selfPath,
  lib,
  hostFacts,
  ...
}:
let
  inherit (hostFacts) forWork;
in
{
  imports = [
    (selfPath "home/common/agents/claude")
    (selfPath "home/common/agents/codex")
    (selfPath "home/common/agents/opencode")
    (selfPath "home/common/apps/browsers/chromium")
    (selfPath "home/common/apps/browsers/zen")
    (selfPath "home/common/apps/desktop/lifesaver.nix")
    (selfPath "home/common/apps/media/mpv.nix")
    (selfPath "home/common/apps/media/yt-dlp")
    (selfPath "home/common/development/editors/nvim")
    (selfPath "home/common/development/environment/direnv")
    (selfPath "home/common/development/source-control/git")
    (selfPath "home/common/development/source-control/lazygit")
    (selfPath "home/common/development/tools/go-task")
    (selfPath "home/common/development/tools/lazydocker")
    (selfPath "home/common/infrastructure/nix/nh.nix")
    (selfPath "home/common/infrastructure/nix/nix-index.nix")
    (selfPath "home/common/infrastructure/services/bloom")
    (selfPath "home/common/infrastructure/services/busy-nas")
    (selfPath "home/common/infrastructure/services/cerberus")
    (selfPath "home/common/infrastructure/services/cupcake")
    (selfPath "home/common/infrastructure/services/k9s")
    (selfPath "home/common/infrastructure/services/pharos")
    (selfPath "home/common/packages")
    (selfPath "home/common/security/rbw.nix")
    (selfPath "home/common/security/ssh-agent.nix")
    (selfPath "home/common/shell/atuin.nix")
    (selfPath "home/common/shell/zsh")
    (selfPath "home/common/terminal/bat")
    (selfPath "home/common/terminal/btop")
    (selfPath "home/common/terminal/eza")
    (selfPath "home/common/terminal/fastfetch")
    (selfPath "home/common/terminal/ghostty")
    (selfPath "home/common/terminal/tmux")
    (selfPath "home/common/terminal/yazi.nix")
    (selfPath "home/common/terminal/zoxide")
    (selfPath "home/common/theme/catppuccin.nix")
  ]
  # Personal-only: dropped on the work Mac.
  ++ lib.optionals (!forWork) [
    (selfPath "home/common/agents/hermes")
    (selfPath "home/common/apps/media/libation.nix")
    (selfPath "home/common/apps/messaging/vesktop.nix")
  ];
}
