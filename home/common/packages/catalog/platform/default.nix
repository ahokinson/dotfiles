args:
builtins.concatLists [
  (import ./disk-usage.nix args)
  (import ./fonts.nix args)
]
