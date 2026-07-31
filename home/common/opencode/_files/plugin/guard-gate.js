// opencode's version of the Claude SessionStart healthcheck plus the PreToolUse
// fail-closed gate.
//
// under permissive permissions the tirith and cupcake guards are the only
// boundary and they fail open, so a silently broken guard means no protection.
// at plugin load (once per opencode session) this runs a health check: the
// binaries are present and a canary confirms a known halt command (rm -rf /) is
// actually blocked. if anything's degraded it blocks all bash for the rest of
// the session. it shares the machine-wide sentinel with the Claude gate, so
// either harness's check drives both.
//
// to recover, run the repair in your own shell rather than through the agent,
// then restart opencode:
//   ./switch.zsh (from the dotfiles repo root, in your own shell)
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync, rmSync } from "node:fs";
import { dirname } from "node:path";

const home = process.env.HOME || "";
const xdg = process.env.XDG_DATA_HOME || `${home}/.local/share`;
const stub = `${xdg}/cupcake-stub`;
const stateDir = process.env.XDG_STATE_HOME || `${home}/.local/state`;
const sentinel = `${stateDir}/guard/degraded`;

const have = (bin) =>
  spawnSync("sh", ["-c", `command -v ${bin}`], { stdio: "ignore" }).status === 0;

function healthProblems() {
  const problems = [];
  if (!have("tirith")) problems.push("tirith (command scanner) not on PATH");
  if (!have("opa")) problems.push("opa (cupcake dep) not on PATH");
  if (!have("cupcake")) {
    problems.push("cupcake (policy engine) not on PATH");
    return problems;
  }
  if (!existsSync(`${stub}/.cupcake/policies/opencode`)) {
    problems.push("cupcake stub missing, run ./switch.zsh");
    return problems;
  }
  // canary: a known halt command must produce a blocking decision. uses the same
  // opencode event shape as cupcake-guard.js. cupcake requires session_id.
  const event = JSON.stringify({
    hook_event_name: "PreToolUse",
    session_id: "guard-healthcheck",
    cwd: home,
    tool: "bash",
    args: { command: "rm -rf /" },
  });
  let blocked = false;
  try {
    const r = spawnSync("cupcake", ["eval", "--harness", "opencode"], {
      cwd: stub,
      input: event,
      encoding: "utf8",
    });
    const d = JSON.parse(r.stdout)?.decision;
    blocked = d === "deny" || d === "block";
  } catch {
    /* parse/spawn error: not blocked */
  }
  if (!blocked)
    problems.push("cupcake did not block rm -rf /, guard not enforcing");
  return problems;
}

// run the check once, at load, before any tool executes.
const problems = healthProblems();
let degraded = problems.length > 0;
try {
  if (degraded) {
    mkdirSync(dirname(sentinel), { recursive: true });
    writeFileSync(sentinel, problems.join(" · "));
    console.error(
      `agent guard healthcheck failed (opencode): ${problems.join(" · ")}; bash gated fail-closed`,
    );
  } else {
    rmSync(sentinel, { force: true });
  }
} catch {
  /* best effort */
}

export const GuardGate = async () => {
  return {
    "tool.execute.before": async (input) => {
      if (input.tool !== "bash") return;
      // honor this session's finding, or a sentinel written by the Claude gate.
      if (degraded || existsSync(sentinel)) {
        throw new Error(
          "Agent command guards are degraded, so bash is blocked fail-closed: the " +
            "tirith/cupcake guards are not currently enforcing. Repair with " +
            "`./switch.zsh` in your shell, then restart opencode.",
        );
      }
    },
  };
};
