{ pkgs, ... }: {
  # skhd is the small, declarative global-hotkey bridge macOS otherwise lacks.
  # macOS asks the user once to grant it Accessibility permission; no idle or
  # login trigger is configured here.
  home.packages = [ pkgs.skhd ];

  xdg.configFile."skhd/skhdrc".text = ''
    # LifeSaver: explicit fullscreen launcher (Command + Option + G).
    alt + cmd - g : ${pkgs.lifesaver}/bin/lifesaver
  '';

  launchd.agents.lifesaver-hotkey = {
    enable = true;
    config = {
      Label = "com.ahokinson.lifesaver-hotkey";
      ProgramArguments = [
        "${pkgs.skhd}/bin/skhd"
        "-c"
        "$HOME/.config/skhd/skhdrc"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
    };
  };
}
