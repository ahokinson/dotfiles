{ pkgs, ... }: {
  home.packages = [ pkgs.yt-dlp ];
  xdg.configFile."yt-dlp/config".text = ''
    --format "bestvideo[height<=1080]+bestaudio/best[height<=1080]"
    --prefer-free-formats

    --output ~/Downloads/%(title)s.%(ext)s
    --no-overwrites

    --embed-thumbnail
    --embed-metadata
    --embed-chapters

    --write-subs
    --sub-langs "en.*,en"

    --cookies-from-browser firefox:~/Library/Application\ Support/zen/Profiles

    --no-playlist
    --ignore-errors
  '';
}
