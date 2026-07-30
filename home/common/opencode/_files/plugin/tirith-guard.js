// tirith scans each bash command before it runs. only a hard block verdict
// (exit 1) denies; safe and advisory commands pass. a missing tirith spawns to
// exit 127, not 1, so it no-ops instead of blocking everything.
export const TirithGuard = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;
      const cmd = output?.args?.command;
      if (!cmd) return;

      const res = await $`tirith check --non-interactive -- ${cmd}`
        .nothrow()
        .quiet();

      if (res.exitCode === 1) {
        throw new Error(
          "Blocked by tirith: dangerous command pattern (e.g. pipe-to-shell, " +
            "homograph URL, terminal injection, data exfiltration). " +
            "Run `tirith check -- '<command>'` to see the findings.",
        );
      }
    },
  };
};
