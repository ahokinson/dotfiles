{ selfPath, ... }: {
  # Template; the real ~/.gitconfig-work is filled in by hand.
  home.file.".gitconfig-work.example".source =
    selfPath "home/common/git/_files/gitconfig-work.example";
}
