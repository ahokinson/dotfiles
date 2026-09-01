import type { Plugin } from "@opencode-ai/plugin"

/**
 * cerberus's opencode plugin. Runs in-process under Bun, so the whole
 * adapter lives here: it shells out to `cerberus guard` on
 * `tool.execute.before` and translates both directions.
 *
 * `tool.execute.before` fires for *every* tool call and opencode has no
 * per-tool matcher config, so GUARDED_TOOLS below does the job cerberus's
 * GUARD_MATCHER does elsewhere, keeping the read path clear.
 *
 * Written against opencode's documented plugin API, not verified against the
 * binary. Unconfirmed parts:
 *   - The camelCase to snake_case remapping (`filePath` -> `file_path`) is
 *     confirmed only for "edit" in opencode's examples; "write" is by
 *     analogy.
 *   - Piping JSON via `new Response(payload)` follows Bun's documented
 *     "Response as stdin" redirection, since `$` has no `.stdin()`.
 * If any of it drifts, the try/catch below fails open rather than
 * mis-blocking.
 */

const GUARDED_TOOLS: Record<string, string> = {
  bash: "Bash",
  edit: "Edit",
  write: "Write",
  webfetch: "WebFetch",
}

function toCanonicalToolInput(tool: string, args: Record<string, unknown>): Record<string, unknown> {
  if (tool !== "edit" && tool !== "write") return args
  const { filePath, ...rest } = args as { filePath?: string; [key: string]: unknown }
  if (filePath === undefined) return args
  return { file_path: filePath, ...rest }
}

export const CerberusGuard: Plugin = async ({ $, directory }) => {
  return {
    "tool.execute.before": async (
      input: { tool: string; sessionID?: string },
      output: { args: Record<string, unknown> },
    ) => {
      const toolName = GUARDED_TOOLS[input.tool]
      if (!toolName) return

      const payload = JSON.stringify({
        session_id: input.sessionID,
        cwd: directory,
        hook_event_name: "PreToolUse",
        tool_name: toolName,
        tool_input: toCanonicalToolInput(input.tool, output.args),
      })

      let stdout = ""
      try {
        const result = await $`cerberus guard < ${new Response(payload)}`.quiet().nothrow()
        stdout = result.stdout.toString().trim()
      } catch {
        // cerberus not on PATH, or the shell call itself failed: fail
        // open, matching cerberus's own fail-open-per-head philosophy for
        // a broken integration layer. A broken plugin must never itself
        // become the reason a call goes ungoverned in a way that looks
        // like it was reviewed.
        return
      }
      if (!stdout) return

      let decision: { hookSpecificOutput?: { permissionDecision?: string; permissionDecisionReason?: string } }
      try {
        decision = JSON.parse(stdout)
      } catch {
        return
      }

      const permission = decision?.hookSpecificOutput?.permissionDecision
      const reason = decision?.hookSpecificOutput?.permissionDecisionReason ?? "Blocked by cerberus"
      if (permission === "deny" || permission === "ask") {
        throw new Error(reason)
      }
    },
  }
}
