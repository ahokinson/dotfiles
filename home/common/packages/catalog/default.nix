# Every catalog module receives the same context argument and returns a flat
# package list. Category entrypoints compose their focused leaves; keep
# home-manager options in ../default.nix.
args:
builtins.concatLists [
  (import ./development args)
  (import ./infrastructure args)
  (import ./media args)
  (import ./personal args)
  (import ./platform args)
  (import ./security args)
  (import ./system args)
]
