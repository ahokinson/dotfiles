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
# that consumes them.
#
# Two token families run opposite to upstream. The `*-oncolor` set (and the
# `fill-onmessage-outgoing-*` fills) is white there because it sits on a
# saturated brand blue; every accent in this palette is a light pastel, so
# those go dark instead. The `*-inverted` set and the dim materials are the
# mirror case - upstream draws them dark-on-light in its dark theme, so they
# stay light here to keep the now-dark oncolor labels readable.
#
# The `fill-*` neutrals are hover, selection, and control-track lifts, not
# accents: upstream defines them as translucent white, and they stay
# translucent here so they read the same over the base, a card, or a dialog
# material.
#
# This block is plain, unlayered CSS on purpose: Signal defines the above
# inside `@layer theme{ :root,:host{...} }` (Tailwind's cascade layer), and
# per the CSS cascade-layers spec, an unlayered rule beats a layered rule of
# the same importance regardless of specificity or source order. `!important`
# is still needed: tailwind.css loads after manifest.css and redefines the
# same tokens unlayered under `@media (prefers-contrast: more)`, and the
# legacy block below fights real `.dark-theme` rules on specificity.
{
  inputs,
  final,
  prev,
  lib,
}:
let
  palette = import (inputs.self + "/home/common/palette.nix");

  alpha = color: pct: "color-mix(in srgb, ${color} ${toString pct}%, transparent)";

  theme = final.writeText "signal-catppuccin.css" ''
    :root, :host {
      /* Surfaces: nav rail, sidebar, message list, cards. */
      --axo-color-surface-primary: ${palette.base} !important;
      --axo-color-surface-secondary: ${palette.mantle} !important;
      --axo-color-surface-tertiary: ${palette.surface0} !important;
      --axo-color-surface-quaternary: ${palette.surface1} !important;
      --axo-color-surface-card: ${palette.surface0} !important;
      --axo-color-surface-message-incoming: ${palette.surface0} !important;
      --axo-color-surface-message-outgoing: ${palette.blue} !important;

      /* Materials: blurred panel backdrops, darkest to lightest. */
      --axo-color-material-dialog: ${palette.mantle} !important;
      --axo-color-material-primary: ${palette.surface0} !important;
      --axo-color-material-secondary: ${palette.surface1} !important;
      --axo-color-material-tertiary: ${palette.surface2} !important;
      --axo-color-material-tertiary-pressed: ${palette.overlay0} !important;
      --axo-color-material-quaternary: ${palette.overlay0} !important;
      --axo-color-material-quaternary-pressed: ${palette.overlay1} !important;
      --axo-color-material-warning: color-mix(in srgb, ${palette.yellow} 18%, ${palette.surface0}) !important;

      /* Dim materials carry oncolor text, so they invert along with it:
         tooltips read as a light chip on dark chrome. */
      --axo-color-material-dim-primary: ${alpha palette.subtext0 92} !important;
      --axo-color-material-dim-secondary: ${alpha palette.overlay2 92} !important;

      /* Text. */
      --axo-color-label-primary: ${palette.text} !important;
      --axo-color-label-secondary: ${palette.subtext0} !important;
      --axo-color-label-placeholder: ${palette.overlay0} !important;
      --axo-color-label-disabled: ${palette.surface2} !important;
      --axo-color-label-accent: ${palette.blue} !important;
      --axo-color-label-destructive: ${palette.red} !important;
      --axo-color-label-affirmative: ${palette.green} !important;
      --axo-color-label-warning: ${palette.yellow} !important;
      --axo-color-label-safety: ${palette.peach} !important;
      --axo-color-label-accent-disabled: ${alpha palette.blue 25} !important;
      --axo-color-label-destructive-disabled: ${alpha palette.red 25} !important;
      --axo-color-label-affirmative-disabled: ${alpha palette.green 25} !important;
      --axo-color-label-warning-disabled: ${alpha palette.yellow 25} !important;
      --axo-color-label-safety-disabled: ${alpha palette.peach 25} !important;

      /* Text and fills sitting on an accent: outgoing bubbles, unread pills,
         primary buttons. Dark, because every accent above is a light pastel. */
      --axo-color-label-primary-oncolor: ${palette.crust} !important;
      --axo-color-label-secondary-oncolor: ${palette.base} !important;
      --axo-color-label-placeholder-oncolor: ${alpha palette.crust 60} !important;
      --axo-color-label-disabled-oncolor: ${alpha palette.crust 40} !important;
      --axo-color-fill-onmessage-outgoing-primary: ${alpha palette.crust 20} !important;
      --axo-color-fill-onmessage-outgoing-primary-pressed: ${alpha palette.crust 24} !important;
      --axo-color-fill-onmessage-outgoing-secondary: ${alpha palette.crust 52} !important;
      --axo-color-fill-onmessage-outgoing-secondary-pressed: ${alpha palette.crust 68} !important;

      /* Inverted chrome: light fills carrying dark labels. */
      --axo-color-fill-inverted: ${palette.text} !important;
      --axo-color-fill-inverted-pressed: ${palette.subtext1} !important;
      --axo-color-label-primary-inverted: ${palette.crust} !important;
      --axo-color-label-secondary-inverted: ${palette.base} !important;
      --axo-color-label-placeholder-inverted: ${alpha palette.crust 50} !important;
      --axo-color-label-disabled-inverted: ${alpha palette.crust 40} !important;

      /* Borders and focus rings. */
      --axo-color-border-primary: ${palette.surface1} !important;
      --axo-color-border-secondary: ${palette.surface2} !important;
      --axo-color-border-tertiary: ${palette.overlay0} !important;
      --axo-color-border-selected: ${palette.blue} !important;
      --axo-color-border-selected-oncolor: ${palette.crust} !important;
      --axo-color-border-focused-inner: ${palette.base} !important;
      --axo-color-border-focused-outer: ${palette.blue} !important;
      --axo-color-border-focused-inner-oncolor: ${palette.text} !important;
      --axo-color-border-focused-outer-oncolor: ${palette.crust} !important;
      --axo-color-deprecated-border-error: ${palette.red} !important;

      /* Neutral fills: hover, selection, control tracks, scrims. */
      --axo-color-fill-primary: ${alpha palette.text 12} !important;
      --axo-color-fill-primary-pressed: ${alpha palette.text 16} !important;
      --axo-color-fill-secondary: ${alpha palette.text 20} !important;
      --axo-color-fill-secondary-pressed: ${alpha palette.text 24} !important;
      --axo-color-fill-tertiary: ${alpha palette.text 36} !important;
      --axo-color-fill-tertiary-pressed: ${alpha palette.text 40} !important;
      --axo-color-fill-control: ${alpha palette.text 12} !important;
      --axo-color-fill-control-pressed: ${alpha palette.text 16} !important;
      --axo-color-fill-overlay: ${alpha palette.crust 60} !important;
      --axo-color-deprecated-fill-on-media: ${alpha palette.crust 75} !important;

      /* Accent fills. affirmative, safety, and the -bright steps reuse their
         own hue when pressed - the palette has no darker green, peach, or
         yellow, and a flat reuse is unnoticeable on a press. */
      --axo-color-brand-primary: ${palette.blue} !important;
      --axo-color-fill-accent: ${palette.blue} !important;
      --axo-color-fill-accent-pressed: ${palette.sapphire} !important;
      --axo-color-fill-accent-bright: ${palette.lavender} !important;
      --axo-color-fill-accent-bright-pressed: ${palette.blue} !important;
      --axo-color-fill-accent-tint: ${alpha palette.blue 12} !important;
      --axo-color-fill-accent-tint-pressed: ${alpha palette.blue 16} !important;
      --axo-color-fill-destructive: ${palette.red} !important;
      --axo-color-fill-destructive-pressed: ${palette.maroon} !important;
      --axo-color-fill-destructive-tint: ${alpha palette.red 12} !important;
      --axo-color-fill-destructive-tint-pressed: ${alpha palette.red 16} !important;
      --axo-color-fill-affirmative: ${palette.green} !important;
      --axo-color-fill-affirmative-pressed: ${palette.green} !important;
      --axo-color-fill-affirmative-bright: ${palette.green} !important;
      --axo-color-fill-affirmative-bright-pressed: ${palette.green} !important;
      --axo-color-fill-affirmative-tint: ${alpha palette.green 12} !important;
      --axo-color-fill-affirmative-tint-pressed: ${alpha palette.green 16} !important;
      --axo-color-fill-warning-bright: ${palette.yellow} !important;
      --axo-color-fill-warning-bright-pressed: ${palette.yellow} !important;
      --axo-color-fill-warning-tint: ${alpha palette.yellow 12} !important;
      --axo-color-fill-warning-tint-pressed: ${alpha palette.yellow 16} !important;
      --axo-color-fill-safety: ${palette.peach} !important;
      --axo-color-fill-safety-pressed: ${palette.peach} !important;
      --axo-color-fill-safety-tint: ${alpha palette.peach 16} !important;
      --axo-color-fill-safety-tint-pressed: ${alpha palette.peach 20} !important;

      /* Panels upstream still addresses by their pre-token names. */
      --axo-color-legacy-conversation-header-bg: ${palette.mantle} !important;
      --axo-color-legacy-signal-conversation-bg: ${palette.mantle} !important;
      --axo-color-legacy-signal-chat-message-bg: ${palette.surface1} !important;
      --axo-color-legacy-official-chat-badge-bg: ${alpha palette.blue 40} !important;
      --axo-color-legacy-official-chat-badge-text: ${palette.lavender} !important;
      --axo-color-legacy-warning-badge: ${palette.peach} !important;
    }

    /* Chrome that predates the token system. Its colors are compiled into the
       rules themselves - there is no `.dark-theme{--...}` block to override,
       only selectors - so this covers the handful that show up in daily use
       rather than all ~500 of them. */
    .dark-theme .module-message__reactions__reaction {
      background: ${palette.surface1} !important;
      border-color: ${palette.base} !important;
    }
    .dark-theme .module-message__reactions__reaction--is-me {
      background: ${palette.blue} !important;
    }
    .dark-theme .module-message__reactions__reaction__count {
      color: ${palette.subtext0} !important;
    }
    .dark-theme .module-message__reactions__reaction__count--is-me {
      color: ${palette.crust} !important;
    }
    .dark-theme .ScrollDownButton {
      background-color: ${palette.surface1} !important;
    }
    .dark-theme .ScrollDownButton__icon--unread-messages,
    .dark-theme .ScrollDownButton__icon--unread-mentions {
      background-color: ${palette.text} !important;
    }
    .ScrollDownButton__badge {
      background-color: ${palette.blue} !important;
      color: ${palette.crust} !important;
    }
    .module-last-seen-indicator__bar {
      background-color: ${palette.surface2} !important;
    }
  '';

  # A renamed class makes the legacy block above quietly stop applying, so
  # fail the build instead - same reasoning as linuxFramePatch's count check.
  legacySelectors = [
    "module-message__reactions__reaction"
    "module-message__reactions__reaction__count--is-me"
    "ScrollDownButton"
    "ScrollDownButton__badge"
    "ScrollDownButton__icon--unread-mentions"
    "module-last-seen-indicator__bar"
  ];

  assertLegacySelectors = ''
    for sel in ${lib.concatStringsSep " " legacySelectors}; do
      if ! grep -q "$sel" "$workDir/stylesheets/manifest.css"; then
        echo "signal overlay: legacy selector $sel not found" >&2
        exit 1
      fi
    done
  '';

  # $out/share/signal-desktop/app.asar on Linux,
  # $out/Applications/Signal.app/Contents/Resources/app.asar on darwin -
  # electron-builder's standard unpacked-resources layout either way.
  relAsarPath =
    if final.stdenv.hostPlatform.isDarwin then
      "Applications/Signal.app/Contents/Resources/app.asar"
    else
      "share/signal-desktop/app.asar";

  # Linux only: Signal never exposes a frame/titleBarStyle override (checked
  # in bundles/main.js - titleBarStyle is isMacOS() ? "hidden" : "default",
  # with no equivalent for frame itself), so getting rid of the native
  # decoration means patching the option object frame is built from. Left
  # alone on darwin, where "hidden" already gives real, native, consistent
  # traffic lights for free.
  #
  # No titlebar, no window controls, full space - COSMIC's own keybinds
  # cover what the controls used to (Super+Q/Alt+F4 close, Super+M maximize,
  # Super+drag anywhere to move; nothing default for minimize). The
  # `module-title-bar-drag-area` div Signal already renders unconditionally
  # is unused by this (it's sized via a --title-bar-drag-area-height Signal
  # only sets on macOS), but harmless at its default zero height.
  #
  # The count assertion mirrors overlays/cosmic-applets.nix - fail the build
  # instead of silently patching nothing if upstream moves this literal.
  linuxFramePatch = lib.optionalString (!final.stdenv.hostPlatform.isDarwin) ''
    sites=$(grep -c 'minWidth:300,minHeight:200,autoHideMenuBar:!1,titleBarStyle:Jv,backgroundColor:d,' "$workDir/bundles/main.js")
    if [ "$sites" != 1 ]; then
      echo "signal overlay: expected 1 main-window options site, found $sites" >&2
      exit 1
    fi
    sed -i \
      's/minWidth:300,minHeight:200,autoHideMenuBar:!1,titleBarStyle:Jv,backgroundColor:d,/minWidth:300,minHeight:200,autoHideMenuBar:!1,frame:!1,titleBarStyle:Jv,backgroundColor:d,/' \
      "$workDir/bundles/main.js"
  '';

  # Darwin only: the bundle records a SHA-256 of the asar's header in
  # Info.plist (ElectronAsarIntegrity), so rewriting the archive leaves that
  # hash describing an archive that no longer exists. Linux builds carry no
  # such field, which is why only macOS is exposed to this. Inert on
  # electron_43 - its enable_embedded_asar_integrity_validation fuse is off -
  # but the day that fuse flips, an app that boots to "integrity check failed"
  # and nothing else is a miserable thing to debug.
  #
  # Via plistlib rather than sed: Info.plist may be in binary format. The
  # KeyError if upstream ever drops the key is deliberate - stop the build
  # rather than ship integrity metadata that means nothing.
  refreshAsarIntegrity =
    let
      script = final.writeText "signal-refresh-asar-integrity.py" ''
        import hashlib, plistlib, struct, sys

        plist_path, asar_path = sys.argv[1], sys.argv[2]
        with open(asar_path, "rb") as f:
            header_len = struct.unpack("<I", f.read(16)[12:16])[0]
            digest = hashlib.sha256(f.read(header_len)).hexdigest()

        raw = open(plist_path, "rb").read()
        fmt = plistlib.FMT_BINARY if raw[:8] == b"bplist00" else plistlib.FMT_XML
        plist = plistlib.loads(raw)

        entry = plist["ElectronAsarIntegrity"]["Resources/app.asar"]
        assert entry["algorithm"] == "SHA256", entry["algorithm"]
        if entry["hash"] == digest:
            raise SystemExit("signal overlay: asar header unchanged, patch did not apply")
        entry["hash"] = digest

        with open(plist_path, "wb") as f:
            plistlib.dump(plist, f, fmt=fmt)
      '';
    in
    lib.optionalString final.stdenv.hostPlatform.isDarwin ''
      ${final.python3}/bin/python3 ${script} \
        "$out/Applications/Signal.app/Contents/Info.plist" \
        "$out/${relAsarPath}"
    '';
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
        ${assertLegacySelectors}
        cat ${theme} >> "$workDir/stylesheets/manifest.css"
        ${linuxFramePatch}
        # electron-builder keeps every native module out of the archive, in a
        # sibling app.asar.unpacked, because Electron cannot dlopen a .node
        # from inside an asar. `asar extract` materialises those back into the
        # tree, so packing without --unpack silently re-absorbs all of them:
        # the archive doubles, app.asar.unpacked is left orphaned, and macOS
        # dies before Signal opens its own log. Every entry upstream unpacks is
        # a .node, and asar's globs are matchBase, so this reproduces the set.
        # Counted rather than assumed, same as the two assertions above.
        asarDir=$(dirname "$out/${relAsarPath}")
        nativesBefore=$(find "$asarDir/app.asar.unpacked" -name '*.node' | wc -l)

        rm -rf "$out/${relAsarPath}" "$asarDir/app.asar.unpacked"
        ${final.asar}/bin/asar pack "$workDir" "$out/${relAsarPath}" --unpack '*.node'
        rm -rf "$workDir"

        nativesAfter=$(find "$asarDir/app.asar.unpacked" -name '*.node' | wc -l)
        if [ "$nativesBefore" != "$nativesAfter" ]; then
          echo "signal overlay: unpacked natives went $nativesBefore -> $nativesAfter" >&2
          exit 1
        fi
        ${refreshAsarIntegrity}

        # bin/signal-desktop's makeWrapper script has prev.signal-desktop's own
        # store path baked into it (as the electron --add-flags target on
        # Linux, as the wrapped Signal.app binary on darwin) - without this it
        # would keep launching the original, unpatched copy we cp -r'd from,
        # never touching the app.asar just rewritten above.
        sed -i "s|${prev.signal-desktop}|$out|g" "$out/bin/signal-desktop"
      '';
}
