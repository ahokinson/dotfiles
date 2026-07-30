// evaluate each bash command against cupcake's global policies (command-regex
// rules like git-guard, plus the global builtins).
//
// cupcake 0.3.0 needs a project ".cupcake/" in the cwd, so eval spawns from the
// stub project (created by the cupcake dotfiles module); the real rules live in
// the global store and apply on top. any error, missing stub, or absent cupcake
// falls through to allow, so a broken layer never blocks work. tirith is its own
// plugin: signal-based policies don't work in the 0.3.0 global evaluator.
export const CupcakeGuard = async ({ directory }) => {
  const home = process.env.HOME || "";
  const xdg = process.env.XDG_DATA_HOME || `${home}/.local/share`;
  const stub = `${xdg}/cupcake-stub`;

  return {
    "tool.execute.before": async (input, output) => {
      // bash goes through the command-regex policies; file and fetch tools go
      // through the sensitive_data / system_protection builtins (path + url
      // checks). forward opencode's native args for each and let cupcake's
      // opencode normalizer map them to tool_input/resolved_file_path. it fails
      // open throughout, so an unrecognized shape just no-ops instead of breaking a read.
      const fileTools = new Set(["read", "webfetch", "grep", "glob"]);
      const isBash = input.tool === "bash";
      if (!isBash && !fileTools.has(input.tool)) return;

      const args = isBash ? { command: output?.args?.command } : output?.args;
      if (isBash ? !args.command : !args) return;

      const event = JSON.stringify({
        hook_event_name: "PreToolUse",
        session_id: input.sessionID || "opencode",
        cwd: directory,
        tool: input.tool,
        args,
      });

      let response;
      try {
        const proc = Bun.spawn(["cupcake", "eval", "--harness", "opencode"], {
          cwd: stub,
          stdin: "pipe",
          stdout: "pipe",
          stderr: "ignore",
        });
        proc.stdin.write(event);
        proc.stdin.end();
        const [out, code] = await Promise.all([
          new Response(proc.stdout).text(),
          proc.exited,
        ]);
        if (code !== 0 || !out) return; // fail-open
        response = JSON.parse(out);
      } catch {
        return; // cupcake absent, stub missing, or parse error: allow
      }

      const d = response?.decision;
      if (d === "deny" || d === "block" || d === "ask") {
        const tag = response.rule_id ? ` [${response.rule_id}]` : "";
        throw new Error(
          `Blocked by cupcake${tag}: ${response.reason || "policy violation"}`,
        );
      }
    },
  };
};
