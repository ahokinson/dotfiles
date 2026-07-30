{ pkgs, lib, ... }:
let
  # Upstream OMZ-style repo roots ship `<name>.plugin.zsh` at the repo root,
  # which is what oh-my-zsh's `is_plugin` check requires. The nixpkgs
  # repackagings strip that entry file, so we fetch the upstream sources
  # directly and symlink them into the OMZ custom dir.
  zsh-syntax-highlighting-src = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "0.8.0";
    hash = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
  };
  zsh-completions-src = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-completions";
    rev = "bf2c5393295fe82d74e3b4585baa483722653ab8";
    hash = "sha256-XPNciTSplIrmaB+2XU+Q7WwVPMrCqSU6LjbwWg5BmE8=";
  };
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Loaded as OMZ plugins below to avoid double-sourcing.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k";
      plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" ];
      # Custom dir under our own home-made symlink farm (populated below).
      custom = "$HOME/.config/zsh/omz-custom";
    };

    history = {
      path = "$HOME/.cache/zsh/history";
      size = 50000;
      save = 50000;
      share = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    shellAliases = { vim = "nvim"; };

# Powerlevel10k instant prompt must be the very first thing in .zshrc, so
    # it goes into `initContent` with `lib.mkBefore` (HM promotes mkBefore
    # content to the head of .zshrc, ahead of the NIX_PROFILES fpath loop
    # and the oh-my-zsh sourcing block). linux/darwin host overlays append
    # via `lib.mkAfter` to `initContent` and will land after the OMZ block
    # (mkAfter > default priority > mkBefore).
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Powerlevel10k instant prompt. Should stay near the top of .zshrc.
        if [[ -r "''${XDG_CONFIG_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CONFIG_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        ZSH_AUTOSUGGEST_STRATEGY=(history)

        export XDG_CONFIG_HOME="$HOME/.config"
        export GOPATH=$HOME/.go
        [[ -d "$HOME/.go/bin" ]] && export PATH=$PATH:$HOME/.go/bin
        export K9S_CONFIG_DIR="$HOME/.config/k9s"
        export LANG=en_US.UTF-8
        export CLAUDE_CODE_TMUX_TRUECOLOR=1

        mkdir -p "$HOME/.cache/zsh"
        export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"

        source "$HOME/.zsh/options.zsh"
        source "$HOME/.zsh/completions.zsh"

        if command -v fzf &>/dev/null; then
          source <(fzf --zsh)
          # Catppuccin Frappe palette for fzf (inline so it stays decoupled
          # from the catppuccin HM module's fzf port, which requires
          # `programs.fzf.enable = true` and would collide with the manual
          # `fzf --zsh` sourcing above). Honors transparent terminal
          # backgrounds by omitting `bg`/`bg+`.
          export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
            --color=fg:#c6d0f5,fg+:#c6d0f5,bg:#303446,bg+:#414559 \
            --color=hl:#ca9ee6,hl+:#babbf1 \
            --color=info:#838ba7,prompt:#ca9ee6,pointer:#f2d5cf \
            --color=marker:#a6d189,spinner:#99d1db,header:#838ba7 \
            --color=border:#414559,gutter:#292c3c,separator:#414559"
        fi

        if command -v tirith &>/dev/null; then
          eval "$(tirith init --shell zsh)"
        fi

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''
    ];
  };

  home.packages = [ pkgs.fzf ];

  # oh-my-zsh custom themes/plugins symlinked into a writable xdg dir.
  # OMZ's theme loader expects a single file `custom/themes/<name>.zsh-theme`,
  # and its plugin loader expects a directory containing `<name>.plugin.zsh`.
  xdg.configFile."zsh/omz-custom/themes/powerlevel10k.zsh-theme".source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  xdg.configFile."zsh/omz-custom/plugins/zsh-autosuggestions".source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
  xdg.configFile."zsh/omz-custom/plugins/zsh-syntax-highlighting".source = "${zsh-syntax-highlighting-src}";
  xdg.configFile."zsh/omz-custom/plugins/zsh-completions".source = "${zsh-completions-src}";

  # Verbatim helpers preserved verbatim from the upstream repo
  home.file.".hushlogin".source = ./_files/.hushlogin;
  home.file.".zsh/options.zsh".source = ./_files/options.zsh;
  home.file.".zsh/completions.zsh".source = ./_files/completions.zsh;
  home.file.".p10k.zsh".source = ./_files/.p10k.zsh;
}