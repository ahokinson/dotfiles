{ selfPath, ... }: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 0;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile (selfPath "home/common/tmux/tmux.conf");
  };
}
