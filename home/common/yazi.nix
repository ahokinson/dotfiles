# enableZshIntegration wires up the `y` shell function (cd-on-quit), which
# a bare package install would not.
_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}
