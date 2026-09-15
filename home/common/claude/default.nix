{
  selfPath,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  wireShared = import (selfPath "home/common/_shared/default.nix") { inherit selfPath; };

  inherit ((import (selfPath "home/common/host.nix") { inherit osConfig; })) forWork;
  # Identical today; hand-edit settingsWorkContent to diverge (permission
  # mode, sandbox allowlist, etc.) the same way settingsContent is hand-edited.
  settingsContent = {
    permissions.defaultMode = "bypassPermissions";
    model = "sonnet[1m]";
    enableAllProjectMcpServers = false;
    statusLine = {
      type = "command";
      command = "pharos statusline scrape";
      refreshInterval = 15;
    };
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash|Write|Edit|NotebookEdit|WebFetch|mcp__.*";
          hooks = [
            {
              type = "command";
              command = "cerberus guard";
            }
          ];
        }
        {
          matcher = ".*";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch tool --tool=claude";
            }
          ];
        }
        {
          matcher = "AskUserQuestion";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch ask --tool=claude";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = ".*";
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch think --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch think --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=claude";
            }
          ];
        }
      ];
      Notification = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux dispatch notify --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
          ];
        }
      ];
      SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "cerberus health";
            }
            {
              type = "command";
              command = "psyche --format claude ~/.claude/plugins/marketplaces/local/plugins/custom/SOUL.md";
            }
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
          ];
        }
      ];
      SessionEnd = [
        {
          hooks = [
            {
              type = "command";
              command = "pharos tmux render --tool=claude";
            }
            {
              type = "command";
              command = "pharos tmux dispatch off --tool=claude";
            }
          ];
        }
      ];
    };
    disableAllHooks = false;
    workflowKeywordTriggerEnabled = false;
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
      "custom@local" = true;
      "gopls-lsp@claude-plugins-official" = true;
      "press@press" = true;
      "pyright-lsp@claude-plugins-official" = true;
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "swift-lsp@claude-plugins-official" = true;
      "typescript-lsp@claude-plugins-official" = true;
    };
    extraKnownMarketplaces.press.source = {
      source = "github";
      repo = "ahokinson/press";
    };
    sandbox = {
      enabled = true;
      allowUnsandboxedCommands = true;
      excludedCommands = [
        "git clone:*"
        "git fetch:*"
        "git ls-remote:*"
        "git pull:*"
        "git push:*"
        "ssh:*"
      ];
      network = {
        allowUnixSockets = [ ];
        allowLocalBinding = true;
        strictAllowlist = true;
        allowedDomains = [
          "grype.anchore.io"
          "toolbox-data.anchore.io"
          "api.armosec.io"
          "astral.sh"
          "*.astral.sh"
          "acli.atlassian.com"
          "bun.sh"
          "*.bun.sh"
          "*.cachix.org"
          "code.claude.com"
          "crates.io"
          "*.crates.io"
          "install.determinate.systems"
          "*.docker.com"
          "docker.io"
          "*.docker.io"
          "cache.flakehub.com"
          "gcr.io"
          "mirror.gcr.io"
          "ghcr.io"
          "github.com"
          "*.github.com"
          "*.githubusercontent.com"
          "go.dev"
          "*.golang.org"
          "gopkg.in"
          "*.hashicorp.com"
          "*.nixos.org"
          "*.npmjs.org"
          "api.osv.dev"
          "pypi.org"
          "*.pypi.org"
          "*.pythonhosted.org"
          "*.rust-lang.org"
          "*.schemastore.org"
          "api.securityscorecards.dev"
          "semgrep.dev"
          "*.semgrep.dev"
          "*.sigstore.dev"
          "taskfile.dev"
          "registry.terraform.io"
          "ziglang.org"
          "*.ziglang.org"
        ];
        deniedDomains = [ "gist.github.com" ];
      };
      filesystem.denyRead = [
        "~/.ssh"
        "~/.aws"
        "~/.gnupg"
        "~/.netrc"
        "**/.env"
        "**/.env.*"
        "**/*.pem"
        "**/*.key"
        "**/*.p12"
        "**/*.pfx"
        "**/*.jks"
        "**/*.keystore"
        "**/id_rsa"
        "**/id_dsa"
        "**/id_ecdsa"
        "**/id_ed25519"
        "**/credentials"
        "**/.credentials"
        "**/.npmrc"
        "**/.pypirc"
      ];
    };
    effortLevel = "xhigh";
    promptSuggestionEnabled = false;
    awaySummaryEnabled = false;
    tui = "fullscreen";
    skipDangerousModePermissionPrompt = true;
    theme = "dark-ansi";
    editorMode = "normal";
    autoCompactEnabled = false;
    fileCheckpointingEnabled = false;
    showTurnDuration = false;
    remoteControlAtStartup = false;
    useAutoModeDuringPlan = false;
  };
  settingsWorkContent = settingsContent;

  settingsJsonFile = pkgs.writeText "claude-settings.json" (
    builtins.toJSON (if forWork then settingsWorkContent else settingsContent)
  );

  # Claude Code rewrites ~/.claude/settings.json at runtime (usage/session
  # state folded into the same file), so it has to stay a real, mutable file
  # rather than a store symlink. This seeds it from the nix-declared defaults
  # above once, on first activation, and never touches it again afterward --
  # same constraint codex/default.nix solves by patching config.toml in
  # place, just seed-once here since Claude Code owns the whole file rather
  # than a few keys within it.
  claudeSettingsSeed = pkgs.writeShellScript "claude-settings-seed" ''
    settingsFile="$HOME/.claude/settings.json"
    [[ -e "$settingsFile" ]] || install -Dm644 ${settingsJsonFile} "$settingsFile"
  '';
in
{
  home.packages = [ pkgs.claude-code ];

  home.file = {
    ".claude" = {
      # known_marketplaces.json has absolute paths baked in and is rewritten
      # per machine, so deploying it collides with the real copy and aborts
      # activation.
      source = lib.cleanSourceWith {
        src = selfPath "home/common/claude/_files";
        filter =
          path: _type:
          !(lib.hasSuffix "/plugins/known_marketplaces.json" path)
          && !(lib.hasSuffix "/_files/keybindings.json" path)
          && !(lib.hasSuffix "/local/.claude-plugin/marketplace.json" path)
          && !(lib.hasSuffix "/custom/.claude-plugin/plugin.json" path);
      };
      recursive = true;
    };

    ".claude/keybindings.json".text = builtins.toJSON {
      "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
      "$docs" = "https://code.claude.com/docs/en/keybindings";
      bindings = [
        {
          context = "Global";
          bindings = {
            "ctrl+t" = "app:toggleTodos";
            "ctrl+o" = "app:toggleTranscript";
            "ctrl+shift+o" = "app:toggleTeammatePreview";
            "ctrl+r" = "history:search";
          };
        }
        {
          context = "Chat";
          bindings = {
            escape = "chat:cancel";
            "ctrl+f" = "chat:killAgents";
            "shift+tab" = "chat:cycleMode";
            "meta+p" = "chat:modelPicker";
            "meta+o" = "chat:fastMode";
            "meta+t" = "chat:thinkingToggle";
            enter = "chat:submit";
            up = "history:previous";
            down = "history:next";
            "ctrl+_" = "chat:undo";
            "ctrl+shift+-" = "chat:undo";
            "ctrl+g" = "chat:externalEditor";
            "ctrl+s" = "chat:stash";
            "ctrl+v" = "chat:imagePaste";
          };
        }
        {
          context = "Autocomplete";
          bindings = {
            tab = "autocomplete:accept";
            escape = "autocomplete:dismiss";
            up = "autocomplete:previous";
            down = "autocomplete:next";
          };
        }
        {
          context = "Settings";
          bindings = {
            escape = "confirm:no";
            up = "select:previous";
            down = "select:next";
            k = "select:previous";
            j = "select:next";
            "ctrl+p" = "select:previous";
            "ctrl+n" = "select:next";
            enter = "select:accept";
            space = "select:accept";
            "/" = "settings:search";
            r = "settings:retry";
          };
        }
        {
          context = "Confirmation";
          bindings = {
            y = "confirm:yes";
            n = "confirm:no";
            enter = "confirm:yes";
            escape = "confirm:no";
            up = "confirm:previous";
            down = "confirm:next";
            tab = "confirm:nextField";
            space = "confirm:toggle";
            "shift+tab" = "confirm:cycleMode";
            "ctrl+e" = "confirm:toggleExplanation";
          };
        }
        {
          context = "Tabs";
          bindings = {
            tab = "tabs:next";
            "shift+tab" = "tabs:previous";
            right = "tabs:next";
            left = "tabs:previous";
          };
        }
        {
          context = "Transcript";
          bindings = {
            "ctrl+e" = "transcript:toggleShowAll";
            escape = "transcript:exit";
          };
        }
        {
          context = "HistorySearch";
          bindings = {
            "ctrl+r" = "historySearch:next";
            escape = "historySearch:accept";
            tab = "historySearch:accept";
            enter = "historySearch:execute";
          };
        }
        {
          context = "Task";
          bindings."ctrl+b" = "task:background";
        }
        {
          context = "ThemePicker";
          bindings."ctrl+t" = "theme:toggleSyntaxHighlighting";
        }
        {
          context = "Help";
          bindings.escape = "help:dismiss";
        }
        {
          context = "Attachments";
          bindings = {
            right = "attachments:next";
            left = "attachments:previous";
            backspace = "attachments:remove";
            delete = "attachments:remove";
            down = "attachments:exit";
            escape = "attachments:exit";
          };
        }
        {
          context = "Footer";
          bindings = {
            right = "footer:next";
            left = "footer:previous";
            enter = "footer:openSelected";
            escape = "footer:clearSelection";
          };
        }
        {
          context = "MessageSelector";
          bindings = {
            up = "messageSelector:up";
            down = "messageSelector:down";
            k = "messageSelector:up";
            j = "messageSelector:down";
            "ctrl+p" = "messageSelector:up";
            "ctrl+n" = "messageSelector:down";
            "ctrl+up" = "messageSelector:top";
            "shift+up" = "messageSelector:top";
            "meta+up" = "messageSelector:top";
            "shift+k" = "messageSelector:top";
            "ctrl+down" = "messageSelector:bottom";
            "shift+down" = "messageSelector:bottom";
            "meta+down" = "messageSelector:bottom";
            "shift+j" = "messageSelector:bottom";
            enter = "messageSelector:select";
          };
        }
        {
          context = "DiffDialog";
          bindings = {
            escape = "diff:dismiss";
            left = "diff:previousSource";
            right = "diff:nextSource";
            up = "diff:previousFile";
            down = "diff:nextFile";
            enter = "diff:viewDetails";
          };
        }
        {
          context = "ModelPicker";
          bindings = {
            left = "modelPicker:decreaseEffort";
            right = "modelPicker:increaseEffort";
          };
        }
        {
          context = "Select";
          bindings = {
            up = "select:previous";
            down = "select:next";
            j = "select:next";
            k = "select:previous";
            "ctrl+n" = "select:next";
            "ctrl+p" = "select:previous";
            enter = "select:accept";
            escape = "select:cancel";
          };
        }
        {
          context = "Plugin";
          bindings = {
            space = "plugin:toggle";
            i = "plugin:install";
          };
        }
      ];
    };

    ".claude/plugins/marketplaces/local/.claude-plugin/marketplace.json".text = builtins.toJSON {
      "$schema" = "https://anthropic.com/claude-code/marketplace.schema.json";
      name = "local";
      description = "Local custom plugins managed via dotfiles";
      owner = {
        name = "anders";
        email = "anders@localhost";
      };
      plugins = [
        {
          name = "custom";
          description = "Custom skills and agents managed via dotfiles";
          source = "./plugins/custom";
          category = "security";
        }
      ];
    };

    ".claude/plugins/marketplaces/local/plugins/custom/.claude-plugin/plugin.json".text =
      builtins.toJSON
        {
          name = "custom";
          description = "Custom skills and agents managed via dotfiles";
          version = "0.1.0";
        };
  }
  // wireShared ".claude/plugins/marketplaces/local/plugins/custom" [
    "docs"
    "system.md"
    "SOUL.md"
  ];

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${claudeSettingsSeed}
  '';
}
