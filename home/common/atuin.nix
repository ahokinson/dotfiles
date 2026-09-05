# Replaces zsh's ctrl-r with atuin's search over synced history. zsh's own
# history files stay authoritative for the shell; atuin only adds the
# search UI, so it coexists with oh-my-zsh/powerlevel10k as-is.
_: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
}
