args:
builtins.concatLists [
  (import ./communication.nix args)
  (import ./entertainment.nix args)
]
