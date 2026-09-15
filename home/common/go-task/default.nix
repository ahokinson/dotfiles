{ pkgs, lib, ... }:
let
  # Task (go-task) global configuration. See: https://taskfile.dev/
  config = lib.generators.toYAML { } {
    version = "3";

    settings = {
      # Run tasks in parallel when possible
      parallel = false;
      # Disable color output
      color = true;
      # Silent mode - only show output from commands
      silent = false;
      # Verbose mode - show full command output
      verbose = false;
      # Force color output even when not in TTY
      force_color = false;
      # Interval to check for changes in watch mode (ms)
      interval = 5000;
    };

    # Default variables available in all taskfiles
    vars.GREETING = "Hello from Task!";

    # Default environment variables
    env = {
      GO111MODULE = "on";
      CGO_ENABLED = "1";
    };

    # Dotenv files to load (if present in project directory)
    dotenv = [
      ".env"
      ".env.local"
    ];

    # Task output style. Options: interleaved, group, prefixed
    output = "prefixed";

    # Run tasks in this directory by default (usually overridden per-project)
    dir = ".";
  };
in
{
  home.packages = [ pkgs.go-task ];
  # $XDG_CONFIG_HOME/task/taskfile.yml on recent versions, ~/.taskfile.yml on
  # older ones. Both are written.
  xdg.configFile."task/taskfile.yml".text = config;
  home.file.".taskfile.yml".text = config;
}
