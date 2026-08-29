{ prev }:
{
  # cosmic-app-list shows the app's name in a tooltip on every dock hover,
  # with no way to turn it off: it calls applet_tooltip unconditionally at all
  # four dock-item call sites, and COSMIC exposes no setting for tooltips
  # anywhere (com.system76.CosmicTk has six keys, none of them this).
  #
  # applet_tooltip's only guard is its has_popup argument. libcosmic builds
  # the tooltip popup inside `(!has_popup).then_some(..)` and reads the flag
  # nowhere else, so passing true leaves the dock item's widget untouched and
  # simply never spawns the popup.
  #
  # `self.popup.is_some(),` - with the trailing comma - occurs only as that
  # argument. The file's other uses of self.popup.is_some() are `if`
  # conditions, which have no comma after them. The count is asserted so this
  # fails the build rather than silently patching nothing if upstream moves.
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
