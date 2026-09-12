# catppuccin.autoEnable (home/linux/catppuccin.nix) themes this via
# programs.waybar.style; the CSS below is layered on top of that import.
#
# Layout mirrors home/linux/cosmic/panel.nix's actual top Panel, not a
# generic waybar look: border_radius = 0 (flat bar, no rounding on the bar
# itself), plugins_center = null (nothing centered - COSMIC's clock sits in
# the right-hand group, its own comment calls it "the macOS menu bar" look),
# left wing a single logo button, right wing Network/Battery/Time/Power in
# that exact order. No per-module pill backgrounds either, for the same
# flat-menu-bar reason - COSMIC's panel items are bare icon+text at rest.
# Icon sizes, padding, font size and inter-module spacing below are likewise
# matched to cosmic-panel-config's PanelSize::XS constants and
# padding_overlap - see the comment on each CSS rule for its specific source
# value.
{
  lib,
  pkgs,
  selfPath,
  osConfig ? null,
  ...
}:
let
  palette = import (selfPath "home/common/palette.nix");
  isApple = (import (selfPath "home/common/host.nix") { inherit osConfig; }).isApple;

  # Same recolor home/linux/icons/default.nix does for COSMIC's app-button
  # logo, re-derived independently here rather than sharing one binding -
  # matches this directory's existing convention (see wallpaper.nix/lock.nix
  # on isApple). Colors are each source SVG's own brand hex, swapped hex-for-
  # hex onto Mocha.
  logo = pkgs.writeText "waybar-logo.svg" (
    if isApple then
      lib.replaceStrings
        [
          "#000000" # the SVG's main linework (8 of 9 fills) - unmapped in
          # icons/default.nix because that usage sits on a light tile where
          # black is the intended glyph color; waybar's bar has no tile
          # behind it, so this needs to be a visible color instead.
          "#2c2c2c"
          "#530900"
          "#d3506f"
          "#a61200"
          "#00a67c"
          "#edbb60"
          "#ffffff"
          "#96caf3"
        ]
        [
          palette.text
          palette.crust
          palette.mantle
          palette.red
          palette.maroon
          palette.teal
          palette.yellow
          palette.text
          palette.sapphire
        ]
        (builtins.readFile (selfPath "home/common/_files/asahi-apple.svg"))
    else
      lib.replaceStrings
        [
          "#699ad7"
          "#7eb1dd"
          "#7ebae4"
          "#415e9a"
          "#4a6baf"
          "#5277c3"
        ]
        [
          palette.sapphire
          palette.sapphire
          palette.sapphire
          palette.blue
          palette.blue
          palette.blue
        ]
        (builtins.readFile "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg")
  );

  # Recolors a WhiteSur-dark status/symbolic SVG the same hex-for-hex way
  # the `logo` binding above does - re-derived independently here rather
  # than sharing one binding, matching this directory's existing
  # convention. Every file in that theme paints itself with one literal
  # fill="#dedede" on its outermost <g>, so a single string replacement is
  # enough here, unlike `logo`'s multi-color source.
  recolor =
    hex: source:
    pkgs.writeText (baseNameOf source) (
      lib.replaceStrings [ "#dedede" ] [ hex ] (builtins.readFile source)
    );

  # home/linux/icons/default.nix installs this exact package and has both
  # toolkits (gtk.iconTheme and wayland.desktopManager.cosmic.appearance.
  # toolkit.icon_theme) inherit WhiteSur-dark from it - these are the
  # literal SVGs COSMIC's own battery/power applets resolve through themed
  # icon lookup, not lookalikes.
  whitesurStatusSymbolic = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur-dark/status/symbolic";
  statusIcon = name: recolor palette.text "${whitesurStatusSymbolic}/${name}.svg";

  powerIcon = statusIcon "system-shutdown-symbolic";

  # Every 10%-point bucket x charge-state combination batteryIconScript
  # below can ask for. All 33 (11 levels x 3 suffixes) exist in the theme,
  # so no bucket needs a nearest-available fallback.
  batteryLevels = [
    0
    10
    20
    30
    40
    50
    60
    70
    80
    90
    100
  ];
  batterySuffixes = [
    ""
    "-charging"
    "-plugged-in"
  ];
  batteryIconKeys = lib.concatMap (
    level: map (suffix: "${toString level}${suffix}") batterySuffixes
  ) batteryLevels;
  batteryIcons = lib.genAttrs batteryIconKeys (key: statusIcon "battery-level-${key}-symbolic");

  # Emits `$path\n$tooltip` per waybar-image(5)'s exec contract. Looks up
  # the battery by power_supply *type* rather than a fixed name: this file
  # is imported by every Hyprland host (modules/nixos/desktop-hyprland.nix),
  # not just this one, and this host's battery is macsmc-battery (Apple
  # Silicon's driver), not the BATn ACPI name framework13-amd-ryzen uses -
  # waybar's own built-in battery module (man 5 waybar-battery)
  # auto-detects the same way for the same reason.
  batteryIconScript = pkgs.writeShellScript "waybar-battery-icon" ''
    set -euo pipefail

    battery=""
    for dir in /sys/class/power_supply/*/; do
      [[ "$(cat "$dir/type" 2>/dev/null)" == "Battery" ]] || continue
      battery="$dir"
      break
    done
    [[ -n "$battery" ]] || exit 1

    capacity="$(cat "$battery/capacity")"
    status="$(cat "$battery/status")"

    # Nearest 10% bucket, clamped - matches the theme's battery-level-N
    # naming (N = 0, 10, 20 ... 100).
    level=$(( (capacity + 5) / 10 * 10 ))
    (( level > 100 )) && level=100

    # POWER_SUPPLY_STATUS values, per the kernel's power-supply sysfs ABI
    # (Documentation/ABI/testing/sysfs-class-power): Unknown, Charging,
    # Discharging, Not charging, Full.
    case "$status" in
      Charging) suffix=-charging ;;
      Full|"Not charging") suffix=-plugged-in ;;
      *) suffix="" ;;
    esac

    case "$level$suffix" in
    ${lib.concatStringsSep "\n    " (
      lib.mapAttrsToList (key: path: "${key}) echo \"${path}\" ;;") batteryIcons
    )}
    esac

    echo "$capacity%"
  '';
in
{
  # Global accent is mauve (home/common/catppuccin.nix); overridden to match
  # COSMIC's own blue accent override (home/linux/cosmic/theme.nix), same as
  # compositor.nix's catppuccin.hyprland.accent.
  catppuccin.waybar.accent = "blue";

  programs.waybar = {
    enable = true;

    # Not systemd: that route binds to hyprland-session.target, whose
    # activation chain (dbus-update-activation-environment && systemctl
    # --user start hyprland-session.target, fired from Hyprland's own
    # exec-once) never reliably completed here, so waybar never started.
    # compositor.nix execs it directly instead - Hyprland's own stock config
    # documents this as the normal way to autostart a status bar.
    systemd.enable = false;

    settings.mainBar = {
      layer = "top";
      height = 32;

      # cosmic-panel-config's shared panel fields (home/linux/cosmic/panel.nix's
      # sharedPanelEntries) set spacing = 0 on both COSMIC bars. Waybar's
      # wiki/man page document this key ("size of gaps between modules")
      # without stating a default, so it's set explicitly rather than relied
      # on.
      spacing = 0;

      # No center group and no workspace count - COSMIC's own panel has
      # neither; a single logo button sits alone on the left there too.
      # custom/spacer is an empty module, not decoration - see its
      # #custom-spacer CSS rule for why, and reused (same definition, one
      # per gap) everywhere that's needed rather than one module per gap.
      modules-left = [
        "custom/spacer"
        "image#logo"
      ];
      modules-right = [
        "network"
        "custom/spacer"
        "image#battery"
        "custom/spacer"
        "clock"
        "image#power"
        "custom/spacer"
      ];

      "custom/spacer" = {
        format = " ";
        tooltip = false;
      };

      "image#logo" = {
        path = "${logo}";
        # cosmic-panel-config's PanelSize::XS.get_applet_icon_size(false) ==
        # 24 (non-symbolic icon size - the AppButton is forced Icon
        # presentation, home/linux/cosmic/panel.nix's panel-button applet
        # config).
        size = 24;
      };

      # Month, day, 24-hour time with seconds, e.g. "Sep 12, 09:33:11" -
      # matches COSMIC's actual panel rendering: no weekday, comma after
      # the day, single space before the time.
      # home/linux/cosmic/panel.nix's military_time/show_seconds applet
      # settings only control the hour format and whether seconds show at
      # all, not weekday or spacing (cosmic-applet-time's own format string).
      clock.format = "{:%b %d, %H:%M:%S}";

      # Waybar's clock module defaults to interval: 60 (man 5 waybar-clock),
      # so %S only advanced once a minute instead of ticking.
      clock.interval = 1;

      # Icon only, no percentage/text - matches COSMIC's network applet
      # exactly (its panel button is bare-icon too; details live in its
      # click-to-open popup, tooltip is the closest waybar equivalent).
      #
      # Left as a Nerd Font glyph, unlike battery/power below: its shape is
      # already close to COSMIC's own themed wifi icon, and a faithful swap
      # needs a live NetworkManager query (wifi vs ethernet vs
      # disconnected, signal-strength bucketing, secure vs open). The same
      # WhiteSur-dark theme has the assets if this is worth revisiting:
      # network-wireless-signal-{excellent,good,ok,weak,none}-symbolic.svg
      # (+ -secure variants) and network-wired-*-symbolic.svg.
      network = {
        format-wifi = "";
        format-ethernet = "";
        format-disconnected = "";
        tooltip-format = "{ifname}: {signalStrength}% via {gwaddr}";
        tooltip-format-ethernet = "{ifname}: connected";
        tooltip-format-disconnected = "Disconnected";
      };

      # Themed SVG, not a glyph - the real battery-level-N-symbolic icon
      # WhiteSur-dark (and so COSMIC's own battery applet, which inherits
      # it - home/linux/icons/default.nix) would draw for this charge
      # state, picked live by batteryIconScript. size = 16 matches
      # PanelSize::XS.get_applet_icon_size(true) == 16, the symbolic icon
      # pixel size.
      "image#battery" = {
        exec = "${batteryIconScript}";
        # Matches the built-in battery module's own default poll cadence
        # (man 5 waybar-battery: interval, default 60).
        interval = 60;
        size = 16;
      };

      # Placeholder for COSMIC's Power applet, which opens a lock/logout/
      # restart/shutdown menu - waybar has no built-in equivalent widget.
      # Wired to the same action as compositor.nix's Super+Shift+Escape for
      # now; swap on-click for a real menu (e.g. wlogout) if that's wanted.
      #
      # Themed SVG (system-shutdown-symbolic.svg), not a glyph - see the
      # #power CSS rule below for why the surrounding padding also changed
      # in this same pass.
      "image#power" = {
        path = "${powerIcon}";
        size = 16;
        on-click = "hyprctl dispatch exit";
        tooltip = false;
      };
    };

    # mkAfter lands this after catppuccin.autoEnable's @import (mkBefore'd),
    # so it can reference the color variables that import defines.
    style = lib.mkAfter ''
      /* text::body's fixed px constant (libcosmic/src/widget/text.rs).
         Context::text() (libcosmic/src/applet/mod.rs) always resolves to
         this at PanelSize::XS, since get_applet_icon_size_with_padding(false)
         (32) <= PanelSize::S's (40) - independent of home/common/fonts.nix's
         pointSize, which only feeds GTK apps/Ghostty. */
      * {
        font-family: "MesloLGS Nerd Font";
        font-size: 14px;
        min-height: 0;
        margin: 0;
        padding: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: @base;
        color: @text;
      }

      /* AppButton is non-symbolic (forced Icon presentation, panel.nix) -
         cosmic-panel-config's PanelSize::XS.get_applet_shrinkable_padding(false)
         == 8 (major/horizontal-axis padding). */
      #logo {
        padding: 0 8px;
      }

      /* Network/Battery/Power are symbolic; Time (clock) explicitly opts
         into the same symbolic spacing via suggested_padding(true) in
         cosmic-applet-time's window.rs, even though it renders text.
         PanelSize::XS.get_applet_shrinkable_padding(true) == 12. */
      #network,
      #battery,
      #clock,
      #power {
        padding: 0 12px;
      }

      /* Breathing room around image#logo/image#battery/image#power. Not
         padding/margin on those modules directly: neither ever visibly
         changed anything on them (verified against the actual loaded
         stylesheet, not just a stale build) - image modules don't grow via
         CSS box-model padding the way #network/#clock's text-based modules
         do. custom/spacer sidesteps that: it's a normal custom (text)
         module, which does. */
      #custom-spacer {
        min-width: 12px;
      }

      /* Nerd Font glyph stands in for libcosmic's raster icon here; 16px is
         the closest analog to PanelSize::XS.get_applet_icon_size(true) == 16
         (symbolic icon pixel size). #battery/#power render real SVGs now
         (their own `size` key sets 16px directly, see the Nix side above),
         not glyphs, so they're dropped from this rule; #clock renders text
         (body, 14px, from the `*` rule above), not a glyph either. */
      #network {
        font-size: 16px;
      }

      /* cosmic-panel-bin's space/layout.rs compacts every non-first applet
         within a wing toward its predecessor by
         get_applet_shrinkable_padding(true) * padding_overlap == 12 * 0.5 ==
         6px (panel.nix's padding_overlap = 0.5). #network is first in
         modules-right so keeps the full gap; the rest pull left. */
      #battery,
      #clock,
      #power {
        margin-left: -6px;
      }
    '';
  };
}
