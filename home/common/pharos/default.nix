{ selfPath, pkgs, ... }:
let
  # Everything except the palette, which is imported from palette.nix below
  # so the two copies (previously hand-duplicated, byte-for-byte) can't drift.
  baseConfig = builtins.fromJSON (builtins.readFile (selfPath "home/common/pharos/config-base.json"));
  palette = import (selfPath "home/common/palette.nix");
in
{
  home.packages = [ pkgs.pharos ];

  # guards.ts is vendored from pharos's examples/; the package ships only the
  # binary. Its guard ids (risk/policy/judgement) must keep matching
  # cerberus's head names, which key the violations file it reads. If they
  # drift, every count silently renders zero.
  xdg.configFile."pharos/guards.ts".source = selfPath "home/common/pharos/_files/guards.ts";

  xdg.configFile."pharos/config.json".text = builtins.toJSON (baseConfig // { inherit palette; });
}
