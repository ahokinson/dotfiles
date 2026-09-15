{ prev }:
{
  # cosmic-app-list calls applet_tooltip unconditionally at all four
  # dock-item call sites, and COSMIC exposes no setting to turn the hover
  # tooltips off.
  #
  # applet_tooltip's only guard is has_popup: libcosmic builds the popup
  # inside `(!has_popup).then_some(..)` and reads the flag nowhere else, so
  # passing true leaves the widget alone and never spawns the popup.
  #
  # The trailing comma is what makes the match unique: the file's other uses
  # of self.popup.is_some() are `if` conditions, with no comma. The count is
  # asserted so the build fails if upstream moves this.
  cosmic-applets = prev.cosmic-applets.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sites=$(grep -c 'self\.popup\.is_some(),' cosmic-app-list/src/app.rs)
      if [ "$sites" != 4 ]; then
        echo "cosmic-applets overlay: expected 4 tooltip call sites, found $sites" >&2
        exit 1
      fi
      substituteInPlace cosmic-app-list/src/app.rs \
        --replace-fail 'self.popup.is_some(),' 'true,'
    '';
  });
}
