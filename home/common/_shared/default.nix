# Maps a subset of docs/system.md/SOUL.md under `prefix`, for the caller to
# merge into its own home.file/xdg.configFile. Used by claude, opencode,
# hermes.
{ selfPath }:
prefix: names:
builtins.listToAttrs (
  map (name: {
    name = "${prefix}/${name}";
    value = {
      source = selfPath "home/common/_shared/${name}";
      recursive = name == "docs";
    };
  }) names
)
