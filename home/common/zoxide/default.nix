# --cmd cd replaces the `cd` builtin with zoxide's wrapper: exact/relative
# paths behave like normal cd, anything else falls back to frecency matching.
{ ... }: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };
}
