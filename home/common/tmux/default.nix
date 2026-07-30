{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 0;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ./tmux.conf;
  };
}