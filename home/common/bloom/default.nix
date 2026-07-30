{ pkgs, ... }: {
  home.packages = [ pkgs.bloom ];

  home.file.".bloom" = {
    source = ./_files;
    recursive = true;
  };
}
