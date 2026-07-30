_: {
  # claude-code reads its config from ~/.claude/.
  home.file.".claude" = {
    source = ./_files;
    recursive = true;
  };
}