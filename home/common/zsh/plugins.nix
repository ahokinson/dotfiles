# Upstream OMZ-style repo roots ship `<name>.plugin.zsh` at the repo root,
# which is what oh-my-zsh's `is_plugin` check requires. The nixpkgs
# repackagings strip that entry file, so this fetches the upstream sources
# directly and symlinks them into the OMZ custom dir.
{ pkgs, ... }:
let
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
  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "powerlevel10k";
    plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" ];
    # Custom dir under our own home-made symlink farm (populated below).
    custom = "$HOME/.config/zsh/omz-custom";
  };

  # oh-my-zsh custom themes/plugins symlinked into a writable xdg dir.
  # OMZ's theme loader expects a single file custom/themes/<name>.zsh-theme,
  # and its plugin loader expects a directory containing <name>.plugin.zsh.
  xdg.configFile."zsh/omz-custom/themes/powerlevel10k.zsh-theme".source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  xdg.configFile."zsh/omz-custom/plugins/zsh-autosuggestions".source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
  xdg.configFile."zsh/omz-custom/plugins/zsh-syntax-highlighting".source = "${zsh-syntax-highlighting-src}";
  xdg.configFile."zsh/omz-custom/plugins/zsh-completions".source = "${zsh-completions-src}";
}
