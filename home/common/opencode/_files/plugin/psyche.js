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
