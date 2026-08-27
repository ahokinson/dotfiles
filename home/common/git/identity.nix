{ selfPath, ... }: {
  # Work identity override template (user fills in ~/.gitconfig-work)
  home.file.".gitconfig-work.example".source =
    selfPath "home/common/git/_files/gitconfig-work.example";
}
