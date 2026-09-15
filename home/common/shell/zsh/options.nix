_: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Loaded as OMZ plugins instead (plugins.nix); this would double-source.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    history = {
      path = "$HOME/.cache/zsh/history";
      size = 50000;
      save = 50000;
      share = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    shellAliases = {
      vim = "nvim";
    };

    # Sourced for non-interactive shells too, unlike initContent.
    envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      export XDG_CONFIG_HOME="$HOME/.config"
    '';
  };
}
