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

// This must remain private: OpenCode's legacy loader treats each exported
// function in the module as a plugin.
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
      await $`pharos tmux dispatch ${state} --tool=opencode`;
    } catch {
      // The status integration must never break OpenCode.
    }
  };

  const render = async (sessionId: string): Promise<void> => {
    const now = Date.now();
    if (now - lastRender < RENDER_INTERVAL_MS) return;
    lastRender = now;
    try {
      const payload = JSON.stringify({ session_id: sessionId });
      await $`echo ${payload} | pharos tmux render --tool=opencode`;
    } catch {
      // The status integration must never break OpenCode.
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
