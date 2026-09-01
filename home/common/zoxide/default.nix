# --cmd cd shadows the builtin: real paths behave normally, anything else
# falls back to frecency matching.
_: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
