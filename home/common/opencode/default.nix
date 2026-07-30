{ pkgs, ... }: {
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode" = {
    source = ./_files;
    recursive = true;
  };

  xdg.configFile."opencode/docs" = {
    source = ../_shared/docs;
    recursive = true;
  };
  xdg.configFile."opencode/system.md".source = ../_shared/system.md;
  xdg.configFile."opencode/SOUL.md".source = ../_shared/SOUL.md;
}
