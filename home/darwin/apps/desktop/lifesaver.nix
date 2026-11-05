{ pkgs, config, ... }: {
  # skhd is the small, declarative global-hotkey bridge macOS otherwise lacks.
  # macOS asks the user once to grant it Accessibility permission; no idle or
  # login trigger is configured here.
  home.packages = [ pkgs.skhd ];

  # xdg.configFile."skhd/skhdrc".text is `types.lines`, so other modules
  # (home/darwin/apps/desktop/yabai.nix) can append their own hotkeys to this
  # same file without conflicting — only one skhd process ever runs it.
  xdg.configFile."skhd/skhdrc".text = ''
    # LifeSaver: explicit fullscreen launcher (Command + Option + G).
    alt + cmd - g : ${pkgs.lifesaver}/bin/lifesaver
  '';

  launchd.agents.lifesaver-hotkey = {
    enable = true;
    config = {
      Label = "com.ahokinson.lifesaver-hotkey";
      # The store path itself, not "$HOME/.config/skhd/skhdrc": home-manager
      # only restarts an agent when its plist content changes (a byte
      # compare), and that runtime path is identical across generations even
      # though the symlink behind it points at a new skhdrc every time. Using
      # the content-addressed source path means any hotkey edit here or in
      # yabai.nix actually changes the plist, so switch restarts skhd instead
      # of leaving it running on stale bindings.
      ProgramArguments = [
        "${pkgs.skhd}/bin/skhd"
        "-c"
        "${config.xdg.configFile."skhd/skhdrc".source}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
    };
  };
}
