args:
builtins.concatLists [
  (import ./filesystem.nix args)
  (import ./networking.nix args)
  (import ./shell.nix args)
]
