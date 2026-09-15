# Boot splash: white Nix snowflake on black, thin progress bar underneath.
# Separate from boot.nix; both are imported by framework13 and asahi-common.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The plymouth the NixOS module itself builds against, so the assets
  # borrowed below cost nothing extra in the closure. Its themesEnv is not
  # usable here: that reads themePackages, which this file defines.
  plymouth = config.boot.plymouth.package;

  # Plymouth draws images at a fixed pixel size, so the mark is scaled per
  # panel: ~12% of height, 180px on framework13's 1504.
  logoFraction = 180.0 / 1504.0;
  logoSize = builtins.floor (config.local.splash.panelHeightPx * logoFraction + 0.5);

  # Rendered from the scalable source. Leaving boot.plymouth.logo unset gets
  # a 48x48 GDM raster instead, visibly soft on a boot screen.
  logo =
    pkgs.runCommand "nix-snowflake-${toString logoSize}.png" { nativeBuildInputs = [ pkgs.librsvg ]; }
      ''
        rsvg-convert \
          --width=${toString logoSize} \
          --height=${toString logoSize} \
          --output=$out \
          ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg
      '';

  # The password-entry widget's images, plus the lock two-step loads with
  # them. Taken from upstream's spinner theme, as every two-step theme does.
  widgetImages = [
    "bullet.png"
    "capslock.png"
    "entry.png"
    "keyboard.png"
    "keymap-render.png"
    "lock.png"
  ];

  # ImageDir is only known once the derivation has an output path, hence the
  # placeholder. DejaVu Sans is the one face boot.plymouth.font puts in the
  # initrd.
  themeConfig = pkgs.writeText "nix.plymouth" ''
    [Plymouth Theme]
    Name=nix
    Description=Nix snowflake on black
    ModuleName=two-step

    [two-step]
    ImageDir=@imagedir@
    Font=DejaVu Sans 12
    TitleFont=DejaVu Sans 30
    Transition=none
    TransitionDuration=0.0
    BackgroundStartColor=0x000000
    BackgroundEndColor=0x000000
    WatermarkHorizontalAlignment=.5
    WatermarkVerticalAlignment=.42
    ProgressBarHorizontalAlignment=.5
    ProgressBarVerticalAlignment=.63
    ProgressBarWidth=300
    ProgressBarHeight=6
    ProgressBarBackgroundColor=0x333333
    ProgressBarForegroundColor=0xffffff

    [boot-up]
    UseAnimation=false
    UseEndAnimation=false
    UseProgressBar=true
    SuppressMessages=true

    [shutdown]
    UseAnimation=false
    UseEndAnimation=false
    UseProgressBar=false
    SuppressMessages=true

    [reboot]
    UseAnimation=false
    UseEndAnimation=false
    UseProgressBar=false
    SuppressMessages=true
  '';

  # The directory name, the .plymouth basename and boot.plymouth.theme below
  # must all read "nix": the NixOS module looks the theme up by name to decide
  # what goes in the initrd, and rewrites ImageDir by matching that path.
  theme = pkgs.runCommand "plymouth-theme-nix" { } ''
    dir=$out/share/plymouth/themes/nix

    # two-step loads the password entry first and discards the whole view if
    # any of its images is missing, dropping to the text splash. Carried even
    # though nothing here asks for a passphrase.
    for image in ${lib.concatStringsSep " " widgetImages}; do
      install -Dm444 ${plymouth}/share/plymouth/themes/spinner/"$image" "$dir/$image"
    done

    # watermark.png, not header-image.png: header-image is positioned against
    # the animation slot, which is off here.
    install -Dm444 ${logo} "$dir/watermark.png"

    # No animation-*.png or throbber-*.png; UseAnimation=false says the same.
    substitute ${themeConfig} "$dir/nix.plymouth" --replace-fail @imagedir@ "$dir"
  '';
in
{
  # The repo's one custom option: no stock NixOS option carries a panel
  # resolution. Namespaced under `local` to stay clear of upstream.
  options.local.splash.panelHeightPx = lib.mkOption {
    type = lib.types.ints.positive;
    default = 1504;
    example = 1890;
    description = ''
      Vertical resolution, in pixels, of the display plymouth draws on. The
      Nix mark is sized as a fixed fraction of it. Defaults to
      framework13-amd-ryzen's 2256x1504 panel.
    '';
  };

  config = {
    boot.plymouth = {
      enable = true;
      theme = "nix";
      themePackages = [ theme ];
      # Also replaces the 48x48 logo.png that themes built against
      # PLYMOUTH_LOGO_FILE fall back to.
      inherit logo;
    };

    # No "splash": the plymouth module appends it. No "loglevel=" either;
    # consoleLogLevel below appends its own further right, and last wins.
    # boot.shell_on_fail keeps a rescue shell reachable despite the silence.
    boot.kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
      "boot.shell_on_fail"
    ];

    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;

    # Upstream lets the splash come down seconds before greetd draws a
    # greeter, showing the bare console. Reversing the order and retaining the
    # last frame gives cosmic-comp something to cut from.
    #
    # greeterManagesPlymouth is the only way to drop greetd's
    # After=plymouth-quit-wait: it comes from the module's unitConfig, so
    # overriding systemd.services.greetd.after would only append.
    services.greetd.greeterManagesPlymouth = true;

    systemd.services.plymouth-quit = {
      after = [ "greetd.service" ];
      # Keeping upstream's "-" prefix: plymouth quit exits non-zero when no
      # plymouthd is running, which is every activation after boot.
      serviceConfig.ExecStart = [
        ""
        "-${plymouth}/bin/plymouth quit --retain-splash"
      ];
    };

    systemd.services.plymouth-quit-wait.after = [ "greetd.service" ];
  };
}
