# Signal Desktop has no theme support, official or otherwise; every known
# way to reskin it patches its packaged app.asar's stylesheet by hand. This
# does the same, generating the override CSS from palette.nix instead of
# vendoring somebody else's stale theme.
#
# Hand-authored against Signal Desktop 8.24.0's real stylesheets (extracted
# from the built package via `asar extract`, not guessed). Its modern chrome
# - nav rail, sidebar, message bubbles, dialogs, buttons, focus rings - reads
# color from a fixed set of `--axo-color-*` custom properties defined once in
# :root (stylesheets/tailwind.css). Overriding those re-themes everything
# that consumes them; whatever Signal hasn't migrated onto that system yet
# (per-conversation bubble colors, a handful of older dialogs) keeps its
# stock color.
#
# This block is plain, unlayered CSS on purpose: Signal defines the above
# inside `@layer theme{ :root,:host{...} }` (Tailwind's cascade layer), and
# per the CSS cascade-layers spec, an unlayered rule beats a layered rule of
# the same importance regardless of specificity or source order - so this
# doesn't need `!important` to win there. It's included anyway as a defense
# against some future Signal version redefining these unlayered elsewhere,
# which would then be an ordinary specificity/order fight.
{
  inputs,
  final,
  prev,
}:
let
  palette = import (inputs.self + "/home/common/palette.nix");

  theme = final.writeText "signal-catppuccin.css" ''
    :root, :host {
      /* Surfaces: sidebar/nav rail, message list background, dialogs, cards. */
      --axo-color-surface-primary: ${palette.base} !important;
      --axo-color-surface-secondary: ${palette.mantle} !important;
      --axo-color-surface-tertiary: ${palette.surface0} !important;
      --axo-color-surface-card: ${palette.surface0} !important;
      --axo-color-surface-message-incoming: ${palette.surface0} !important;
      --axo-color-surface-message-outgoing: ${palette.blue} !important;
      --axo-color-material-dialog: ${palette.mantle} !important;
      --axo-color-material-primary: ${palette.surface0} !important;
      --axo-color-material-secondary: ${palette.surface1} !important;
      --axo-color-material-tertiary: ${palette.surface2} !important;
      --axo-color-material-quaternary: ${palette.overlay0} !important;

      /* Text. label-primary-oncolor/-secondary-oncolor sit on the outgoing
         bubble above, now a light accent blue instead of Signal's saturated
         brand blue - dark text keeps them readable there. */
      --axo-color-label-primary: ${palette.text} !important;
      --axo-color-label-secondary: ${palette.subtext0} !important;
      --axo-color-label-placeholder: ${palette.overlay0} !important;
      --axo-color-label-disabled: ${palette.surface2} !important;
      --axo-color-label-primary-oncolor: ${palette.base} !important;
      --axo-color-label-secondary-oncolor: ${palette.surface1} !important;
      --axo-color-label-accent: ${palette.blue} !important;
      --axo-color-label-destructive: ${palette.red} !important;
      --axo-color-label-affirmative: ${palette.green} !important;
      --axo-color-label-warning: ${palette.yellow} !important;
      --axo-color-label-safety: ${palette.peach} !important;

      /* Borders and focus rings. */
      --axo-color-border-primary: ${palette.surface1} !important;
      --axo-color-border-secondary: ${palette.surface2} !important;
      --axo-color-border-tertiary: ${palette.overlay0} !important;
      --axo-color-border-selected: ${palette.blue} !important;
      --axo-color-border-focused-inner: ${palette.base} !important;
      --axo-color-border-focused-outer: ${palette.blue} !important;

      /* Buttons/fills. affirmative and safety don't get distinct pressed
         hues - the palette has no natural darker green/peach step, and a
         flat reuse is unnoticeable on a press. */
      --axo-color-brand-primary: ${palette.blue} !important;
      --axo-color-fill-primary: ${palette.blue} !important;
      --axo-color-fill-primary-pressed: ${palette.sapphire} !important;
      --axo-color-fill-secondary: ${palette.surface1} !important;
      --axo-color-fill-secondary-pressed: ${palette.surface2} !important;
      --axo-color-fill-tertiary: ${palette.surface0} !important;
      --axo-color-fill-tertiary-pressed: ${palette.surface1} !important;
      --axo-color-fill-accent: ${palette.blue} !important;
      --axo-color-fill-accent-pressed: ${palette.sapphire} !important;
      --axo-color-fill-accent-bright: ${palette.lavender} !important;
      --axo-color-fill-accent-bright-pressed: ${palette.blue} !important;
      --axo-color-fill-destructive: ${palette.red} !important;
      --axo-color-fill-destructive-pressed: ${palette.maroon} !important;
      --axo-color-fill-affirmative: ${palette.green} !important;
      --axo-color-fill-affirmative-pressed: ${palette.green} !important;
      --axo-color-fill-warning-bright: ${palette.yellow} !important;
      --axo-color-fill-safety: ${palette.peach} !important;
      --axo-color-fill-safety-pressed: ${palette.peach} !important;
      --axo-color-fill-control: ${palette.surface1} !important;
      --axo-color-fill-control-pressed: ${palette.surface2} !important;
      --axo-color-fill-inverted: ${palette.crust} !important;
      --axo-color-fill-inverted-pressed: ${palette.mantle} !important;
    }
  '';

  # $out/share/signal-desktop/app.asar on Linux,
  # $out/Applications/Signal.app/Contents/Resources/app.asar on darwin -
  # electron-builder's standard unpacked-resources layout either way.
  relAsarPath =
    if final.stdenv.hostPlatform.isDarwin then
      "Applications/Signal.app/Contents/Resources/app.asar"
    else
      "share/signal-desktop/app.asar";
in
{
  # Built as a copy-and-patch over the already-built prev.signal-desktop
  # rather than prev.signal-desktop.overrideAttrs: overrideAttrs changes the
  # derivation that produces app.asar in the first place, which reruns
  # Signal's own pnpm/electron-builder build from scratch (there being no
  # substitute for a hash nobody else has built) for what is otherwise a
  # single post-hoc file edit. This instead takes the finished, cache-
  # substituted output and only redoes the asar.
  signal-desktop =
    final.runCommand "signal-desktop-${prev.signal-desktop.version}"
      {
        nativeBuildInputs = [ final.asar ];
        meta = prev.signal-desktop.meta;
      }
      ''
        cp -r ${prev.signal-desktop} $out
        chmod -R u+w $out

        workDir=$(mktemp -d)
        ${final.asar}/bin/asar extract "$out/${relAsarPath}" "$workDir"
        cat ${theme} >> "$workDir/stylesheets/manifest.css"
        rm "$out/${relAsarPath}"
        ${final.asar}/bin/asar pack "$workDir" "$out/${relAsarPath}"
        rm -rf "$workDir"

        # bin/signal-desktop's makeWrapper script has prev.signal-desktop's own
        # store path baked into it (as the electron --add-flags target on
        # Linux, as the wrapped Signal.app binary on darwin) - without this it
        # would keep launching the original, unpatched copy we cp -r'd from,
        # never touching the app.asar just rewritten above.
        sed -i "s|${prev.signal-desktop}|$out|g" "$out/bin/signal-desktop"
      '';
}
