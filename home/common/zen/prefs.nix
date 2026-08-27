{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  prefs = import (selfPath "home/common/zen/data.nix") { inherit pkgs selfPath; };

  toPrefLiteral =
    value:
    if builtins.isBool value then
      (if value then "true" else "false")
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else
      builtins.toJSON value;
in
pkgs.writeText "zen-user.js" (
  lib.concatStringsSep "\n" (
    lib.sort builtins.lessThan (
      lib.mapAttrsToList (
        name: value: "user_pref(${builtins.toJSON name}, ${toPrefLiteral value});"
      ) prefs
    )
  )
  + "\n"
)
