_: {
  # Runs inside home-manager's catppuccin plugin block, before this file's
  # own extraConfig below - @catppuccin_status_background is read once, when
  # the plugin's run-shell executes. "none" makes it set status-style to
  # tmux's literal "default" instead of bg=#{@thm_mantle}, so the bar falls
  # through to ghostty's background-opacity (background-opacity-cells is
  # false there, so window-status-format's explicit thm_* pill colors below
  # stay solid - same frosted-glass shape as everywhere else in the repo).
  catppuccin.tmux.extraConfig = ''
    set -g @catppuccin_status_background "none"
  '';

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 0;
    terminal = "tmux-256color";
    extraConfig = ''
      # Reload
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Sanity
      set -g prefix C-b
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1

      # Vim-like
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind X confirm-before kill-session
      bind c new-window -c "#{pane_current_path}"

      # Colour
      set -g default-terminal "tmux-256color"
      # Forward 24-bit colour to ghostty (paired with CLAUDE_CODE_TMUX_TRUECOLOR=1 in zsh).
      set -as terminal-features ",xterm-ghostty:RGB"

      # The catppuccin plugin, its flavor and its "basic" window-status style all come
      # from home-manager's plugin block, which tmux runs before this file. The two
      # formats below land after it and replace the ones it built.
      set -g window-status-current-format "#[fg=#{@thm_crust},bg=#{@thm_mauve}] #I #[fg=#{@thm_fg},bg=#{@thm_surface_1}] #W #[default]"
      set -g window-status-format "#[fg=#{@thm_crust},bg=#{@thm_overlay_2}] #I #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #W #[default]"

      set -g status-left-length 100
      set -g status-right-length 20
      set -g status-left " "
      set -g status-right " "
      set -g status on
      set -g status-position bottom
      set -gu status-format[1]
      set -gu status-format[2]
    '';
  };
}
