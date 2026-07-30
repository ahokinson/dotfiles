# Overlay that exposes the hermes-agent + zen-browser flake inputs under `pkgs`
# so per-tool home modules can pull them without spelling out `inputs.*`.
inputs: final: prev: {
  hermes-agent = inputs.hermes-agent.packages.${final.stdenv.hostPlatform.system}.default
    or prev.hermes-agent or null;
  zen-browser = inputs.zen-browser.packages.${final.stdenv.hostPlatform.system}.default
    or prev.zen-browser or null;
}