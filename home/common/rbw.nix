# No `settings` block: rbw's settings.email has no default, so declaring
# settings at all requires an account email in the repo. Configure per
# machine instead: `rbw config set email <addr>` and
# `rbw config set pinentry <path>`.
_: {
  programs.rbw.enable = true;
}
