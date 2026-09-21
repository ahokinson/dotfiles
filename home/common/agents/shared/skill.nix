# Renders SKILL.md under `prefix/<name>` for each name: the caller's own
# per-tool frontmatter (frontmatterDir/<name>.md) plus the shared body
# (home/common/agents/shared/skills/<name>/body.md), and copies that skill's
# references/ alongside it when it has one. Used by claude and opencode so
# the two tools' skills share body content without sharing frontmatter.
{ selfPath, lib }:
prefix: frontmatterDir: names:
lib.foldl' (
  acc: name:
  let
    skillDir = "home/common/agents/shared/skills/${name}";
    hasReferences = builtins.pathExists (selfPath "${skillDir}/references");
  in
  acc
  // {
    "${prefix}/${name}/SKILL.md".text =
      builtins.readFile (selfPath "${frontmatterDir}/${name}.md")
      + "\n"
      + builtins.readFile (selfPath "${skillDir}/body.md");
  }
  // lib.optionalAttrs hasReferences {
    "${prefix}/${name}/references" = {
      source = selfPath "${skillDir}/references";
      recursive = true;
    };
  }
) { } names
