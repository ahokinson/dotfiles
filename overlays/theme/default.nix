{
  inputs,
  final,
  prev,
}:
import ./signal.nix {
  inherit inputs final prev;
  inherit (final) lib;
}
