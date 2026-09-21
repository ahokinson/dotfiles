{
  selfPath,
  pkgs,
  lib,
  hostFacts,
  ...
}:
let
  wireShared = import (selfPath "home/common/agents/shared/default.nix") { inherit selfPath; };
  wireSkills = import (selfPath "home/common/agents/shared/skill.nix") { inherit selfPath lib; };
  skillNames = [
    "code-security"
    "container-security"
    "iac-security"
    "pipeline-security"
    "supply-chain-security"
    "technical-documentation"
    "threat-modeling"
  ];

  inherit (hostFacts) forWork;
  # Identical today; hand-edit opencodeWorkConfig to diverge (model/provider,
  # permission mode, etc.) the same way opencodeConfig is hand-edited.
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    model = "opencode-go/glm-5";
    small_model = "ollama/hf.co/bartowski/Dolphin3.0-Llama3.2-3B-GGUF:Q5_K_M";
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Local";
      options.baseURL = "http://localhost:11434/v1";
      models = {
        "hf.co/bartowski/Dolphin3.0-Llama3.2-3B-GGUF:Q5_K_M" = {
          name = "Dolphin3.0 3B";
          limit = {
            context = 131072;
            output = 32768;
          };
        };
        "hf.co/bartowski/NousResearch_Hermes-4-14B-GGUF:Q5_K_M" = {
          name = "Hermes 4 14B";
          limit = {
            context = 131072;
            output = 32768;
          };
        };
        "hf.co/unsloth/DeepSeek-R1-Distill-Qwen-14B-GGUF:Q5_K_M" = {
          name = "DeepSeek R1 14B";
          limit = {
            context = 131072;
            output = 32768;
          };
        };
        "hf.co/unsloth/gemma-4-12b-it-GGUF:Q5_K_M" = {
          name = "Gemma 4 12B";
          limit = {
            context = 131072;
            output = 32768;
          };
        };
        "hf.co/unsloth/Qwen3.5-4B-GGUF:Q5_K_M" = {
          name = "Qwen3.5 4B";
          limit = {
            context = 131072;
            output = 32768;
          };
        };
      };
    };
    permission = {
      edit = "allow";
      write = "allow";
      bash."*" = "allow";
      read = {
        "*" = "allow";
        "**/.env" = "deny";
        "**/.env.*" = "deny";
        "**/*.pem" = "deny";
        "**/*.key" = "deny";
        "**/*.p12" = "deny";
        "**/*.pfx" = "deny";
        "**/*.jks" = "deny";
        "**/*.keystore" = "deny";
        "**/id_rsa" = "deny";
        "**/id_dsa" = "deny";
        "**/id_ecdsa" = "deny";
        "**/id_ed25519" = "deny";
        "**/credentials" = "deny";
        "**/.credentials" = "deny";
        "**/.npmrc" = "deny";
        "**/.pypirc" = "deny";
        "~/.aws/**" = "deny";
        "~/.gnupg/**" = "deny";
        "~/.netrc" = "deny";
        "~/.ssh/**" = "deny";
      };
      webfetch = "ask";
    };
    share = "disabled";
    autoupdate = false;
    instructions = [ "system.md" ];
    agent = {
      build.disable = false;
      plan.disable = false;
    };
  };
  opencodeWorkConfig = opencodeConfig;
in
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile = {
    "opencode" = {
      source = lib.cleanSourceWith {
        src = selfPath "home/common/agents/opencode/_files";
        filter =
          path: _type:
          !(lib.hasSuffix "/_files/opencode.json" path)
          && !(lib.hasSuffix "/_files/opencode-work.json" path)
          && !(lib.hasSuffix "/_files/tui.json" path)
          && !(lib.hasSuffix "/plugin/cerberus-guard.ts" path)
          && !(lib.hasSuffix "/plugin/pharos.ts" path)
          && !(lib.hasSuffix "/plugin/psyche.js" path)
          && !(lib.hasSuffix "/themes/catppuccin-mocha.json" path);
      };
      recursive = true;
      # tui.json gets rewritten by opencode itself on every launch, even when
      # nothing changed, unlinking home-manager's symlink. Force keeps
      # switches self-healing instead of backup-colliding with that churn.
      force = true;
    };

    "opencode/opencode.json" = {
      text = builtins.toJSON (if forWork then opencodeWorkConfig else opencodeConfig);
      force = true;
    };

    "opencode/tui.json" = {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/tui.json";
        theme = "catppuccin-mocha";
      };
      force = true;
    };

    "opencode/themes/catppuccin-mocha.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/theme.json";
      defs = {
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
        surface0 = "#313244";
        surface1 = "#45475a";
        surface2 = "#585b70";
        overlay0 = "#6c7086";
        overlay1 = "#7f849c";
        overlay2 = "#9399b2";
        subtext0 = "#a6adc8";
        subtext1 = "#bac2de";
        text = "#cdd6f4";
        lavender = "#b4befe";
        blue = "#89b4fa";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        teal = "#94e2d5";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        peach = "#fab387";
        maroon = "#eba0ac";
        red = "#f38ba8";
        mauve = "#cba6f7";
        pink = "#f5c2e7";
        flamingo = "#f2cdcd";
        rosewater = "#f5e0dc";
      };
      theme = {
        primary = "blue";
        secondary = "mauve";
        accent = "pink";
        error = "red";
        warning = "peach";
        success = "green";
        info = "sky";
        text = "text";
        textMuted = "subtext0";
        # "none" (not a hex ref) lets the terminal's own background show
        # through - matches the repo-wide frosted-glass pass. backgroundElement
        # stays opaque so hovered/selected rows keep contrast against it.
        background = "none";
        backgroundPanel = "none";
        backgroundElement = "surface0";
        border = "mauve";
        borderActive = "pink";
        borderSubtle = "lavender";
        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "subtext0";
        diffHunkHeader = "mauve";
        diffHighlightAdded = "teal";
        diffHighlightRemoved = "maroon";
        diffAddedBg = "surface0";
        diffRemovedBg = "surface0";
        diffContextBg = "mantle";
        diffLineNumber = "lavender";
        diffAddedLineNumberBg = "surface0";
        diffRemovedLineNumberBg = "surface0";
        markdownText = "text";
        markdownHeading = "mauve";
        markdownLink = "blue";
        markdownLinkText = "sapphire";
        markdownCode = "teal";
        markdownBlockQuote = "pink";
        markdownEmph = "peach";
        markdownStrong = "red";
        markdownHorizontalRule = "lavender";
        markdownListItem = "yellow";
        markdownListEnumeration = "sky";
        markdownImage = "pink";
        markdownImageText = "rosewater";
        markdownCodeBlock = "surface1";
        syntaxComment = "overlay1";
        syntaxKeyword = "mauve";
        syntaxFunction = "blue";
        syntaxVariable = "flamingo";
        syntaxString = "green";
        syntaxNumber = "peach";
        syntaxType = "yellow";
        syntaxOperator = "sky";
        syntaxPunctuation = "teal";
      };
    };

    "opencode/plugin/cerberus-guard.ts" = {
      force = true;
      text = ''
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
                const result = await $`cerberus guard < ''${new Response(payload)}`.quiet().nothrow()
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
      '';
    };

    "opencode/plugin/pharos.ts" = {
      force = true;
      text = ''
        // Connects OpenCode events to pharos's tmux status integration.

        const RENDER_INTERVAL_MS = 5000;

        type PulseState = "think" | "tool" | "ask" | "off";

        interface PartEventProperties {
          sessionID?: string;
          part?: {
            type?: string;
            tool?: string;
            state?: { status?: string };
          };
        }

        interface BusEvent {
          type?: string;
          properties?: unknown;
        }

        function propertiesOf(event: BusEvent): PartEventProperties {
          return (event.properties as PartEventProperties | undefined) ?? {};
        }

        // Must stay private: OpenCode's legacy loader treats every exported function
        // in the module as a plugin.
        function pulseStateFor(event: BusEvent): PulseState | null {
          if (event.type === "session.idle") return "off";
          if (event.type !== "message.part.updated") return null;
          const part = propertiesOf(event).part;
          if (!part) return null;
          if (part.type === "tool") {
            if (part.state?.status !== "running") return null;
            return part.tool === "question" ? "ask" : "tool";
          }
          if (part.type === "text" || part.type === "reasoning" || part.type === "step-start") return "think";
          return null;
        }

        type Shell = (strings: TemplateStringsArray, ...values: unknown[]) => Promise<unknown>;

        export const PharosBridge = async ({ $ }: { $: Shell }) => {
          let lastState: PulseState | null = null;
          let lastRender = 0;

          const dispatch = async (state: PulseState): Promise<void> => {
            if (state === lastState) return;
            lastState = state;
            try {
              await $`pharos tmux dispatch ''${state} --tool=opencode`;
            } catch {
              // Best effort; never break OpenCode over the status line.
            }
          };

          const render = async (sessionId: string): Promise<void> => {
            const now = Date.now();
            if (now - lastRender < RENDER_INTERVAL_MS) return;
            lastRender = now;
            try {
              const payload = JSON.stringify({ session_id: sessionId });
              await $`echo ''${payload} | pharos tmux render --tool=opencode`;
            } catch {
              // Best effort; never break OpenCode over the status line.
            }
          };

          return {
            event: async ({ event }: { event: BusEvent }) => {
              if (event.type === "session.idle") {
                await dispatch("off");
                lastRender = 0;
                const sessionId = propertiesOf(event).sessionID;
                if (sessionId) await render(sessionId);
                return;
              }

              const state = pulseStateFor(event);
              if (state) await dispatch(state);

              if (event.type === "session.updated") {
                const sessionId = propertiesOf(event).sessionID;
                if (sessionId) await render(sessionId);
              }
            },
          };
        };
      '';
    };

    "opencode/plugin/psyche.js" = {
      force = true;
      text = ''
        // Pushes psyche's rendered SOUL content onto opencode's system prompt.
        export const Psyche = async ({ $ }) => {
          return {
            "experimental.chat.system.transform": async (_input, output) => {
              try {
                const result = await $`psyche --format opencode ~/.config/opencode/SOUL.md`.quiet();
                const text = result.stdout.toString().trim();
                if (text) output.system.push(text);
              } catch {
                // psyche failing to run must never break the chat session.
              }
            },
          };
        };
      '';
    };
  }
  // wireShared "opencode" [
    "docs"
    "system.md"
    "SOUL.md"
  ]
  // wireSkills "opencode/skill" "home/common/agents/opencode/_skills" skillNames;
}
