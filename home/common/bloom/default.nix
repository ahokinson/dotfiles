{ pkgs, ... }: {
  # bloom binary is currently provided upstream via the `ahokinson/tap/bloom` Homebrew
  # tap. Until a Nix flake input is wired, install it manually on each host and
  # we'll manage only its config here.
  home.file.".bloom" = {
    source = ./_files;
    recursive = true;
  };
}