# cosmic-workspaces-epoch's per-window icon lookup (src/desktop_info.rs)
# never calls .with_theme(...) on its cosmic-freedesktop-icons lookup, which
# defaults to "hicolor" when unset - so the Workspaces overview always shows
# the stock/hicolor icon regardless of the configured icon theme
# (home/linux/desktop/icons), unlike cosmic-panel's CosmicAppList applet,
# which does resolve through it. The file's own top comment says this
# function was "Coppied from cosmic-app-list"; this restores what that copy
# left out.
{ prev }:
{
  cosmic-workspaces-epoch = prev.cosmic-workspaces-epoch.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sites=$(grep -c 'freedesktop_icons::lookup(de.icon().unwrap_or(&de.appid))' src/desktop_info.rs)
      if [ "$sites" != 1 ]; then
        echo "cosmic-workspaces-epoch overlay: expected 1 icon lookup site, found $sites" >&2
        exit 1
      fi
      substituteInPlace src/desktop_info.rs \
        --replace-fail \
          'freedesktop_icons::lookup(de.icon().unwrap_or(&de.appid))' \
          'freedesktop_icons::lookup(de.icon().unwrap_or(&de.appid)).with_theme("WhiteSur-dark-catppuccin")'
    '';
  });
}
