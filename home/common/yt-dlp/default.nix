{ pkgs, ... }: {
  home.packages = [ pkgs.yt-dlp ];
  xdg.configFile."yt-dlp/config".source = ./config;
}