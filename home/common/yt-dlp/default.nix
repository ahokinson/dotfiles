{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.yt-dlp ];
  xdg.configFile."yt-dlp/config".source = selfPath "home/common/yt-dlp/config";
}
