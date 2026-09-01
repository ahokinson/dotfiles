# Boot splash: a white Nix snowflake on black with a thin progress bar under
# it, the layout macOS boots with. Kept separate from boot.nix because the
# splash is a look and that module is a bootloader; both are imported by
# hosts/framework13-amd-ryzen and hosts/asahi-common.nix.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The plymouth the NixOS module itself builds against, so borrowing assets
  # below costs nothing extra in the closure. Its themesEnv is not usable here:
  # that reads themePackages, which this file defines.
  plymouth = config.boot.plymouth.package;

  # Plymouth draws images at a fixed pixel size, so the mark is sized per
  # machine rather than in relative units. 180px on the Framework's 2256x1504
  # panel is ~12% of its height, the proportion macOS gives its own boot mark;
  # that ratio is what carries across to a differently sized panel.
  logoFraction = 180.0 / 1504.0;
  logoSize = builtins.floor (config.local.splash.panelHeightPx * logoFraction + 0.5);

  # Rendered from the scalable source. Leaving boot.plymouth.logo unset gets a
  # 48x48 raster instead - sized for GDM, and visibly soft on a boot screen.
  logo =
    pkgs.runCommand "nix-snowflake-${toString logoSize}.png" { nativeBuildInputs = [ pkgs.librsvg ]; }
      ''
        rsvg-convert \
          --width=${toString logoSize} \
          --height=${toString logoSize} \
          --output=$out \
          ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg
      '';

  # The password-entry widget's images, plus the lock two-step loads alongside
  # them. Upstream's spinner theme is where every other two-step theme takes
  # this set from.
  widgetImages = [
    "bullet.png"
    "capslock.png"
    "entry.png"
    "keyboard.png"
    "keymap-render.png"
    "lock.png"
  ];

  # ImageDir is only known once the derivation has an output path, hence the
  # placeholder rather than a plain writeText. DejaVu Sans is the one face
  # boot.plymouth.font puts in the initrd.
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

  # The directory name, the .plymouth basename, and boot.plymouth.theme below
  # all have to read "nix": the NixOS plymouth module looks the theme up by
  # name to decide what to carry into the initrd, and rewrites ImageDir by
  # matching on that path.
  theme = pkgs.runCommand "plymouth-theme-nix" { } ''
    dir=$out/share/plymouth/themes/nix

    # two-step loads the password entry before anything else and discards the
    # whole view if one of its images is missing, dropping plymouth to the text
    # splash. The theme carries them even though nothing here asks for a
    # passphrase.
    for image in ${lib.concatStringsSep " " widgetImages}; do
      install -Dm444 ${plymouth}/share/plymouth/themes/spinner/"$image" "$dir/$image"
    done

    # watermark.png, not header-image.png: header-image is positioned relative
    # to the animation slot, which is off here, while the watermark carries its
    # own alignment. It is the slot nixpkgs' own plymouth module uses to drop
    # this logo into the upstream spinner theme.
    install -Dm444 ${logo} "$dir/watermark.png"

    # No animation-*.png or throbber-*.png: those strips are what the previous
    # catppuccin theme drew as a row of colored dots. UseAnimation=false in the
    # config says the same thing a second time.
    substitute ${themeConfig} "$dir/nix.plymouth" --replace-fail @imagedir@ "$dir"
  '';
in
{
  # The repo's one custom option. Every other module here is plain config,
  # but the logo size has to come from the host and there is no stock NixOS
  # option carrying a panel resolution. Namespaced under `local` so it cannot
  # collide with anything upstream adds.
  options.local.splash.panelHeightPx = lib.mkOption {
    type = lib.types.ints.positive;
    default = 1504;
    example = 1890;
    description = ''
      Vertical resolution, in pixels, of the display plymouth draws on. The
      Nix mark is sized as a fixed fraction of it, so a taller panel gets a
      proportionally larger logo instead of a small one adrift in black.
      Defaults to framework13-amd-ryzen's 2256x1504 panel.
    '';
  };

  config = {
    boot.plymouth = {
      enable = true;
      theme = "nix";
      themePackages = [ theme ];
      # Also replaces the 48x48 logo.png that themes compiled against
      # PLYMOUTH_LOGO_FILE fall back to.
      inherit logo;
    };

    # No "splash" here - the plymouth module appends it. No "loglevel=" either:
    # consoleLogLevel below appends its own further right on the command line,
    # and the last one wins. vt.global_cursor_default=0 hides the console cursor
    # if anything does expose it; boot.shell_on_fail keeps a rescue shell
    # reachable despite the silence.
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

    # Upstream orders plymouth-quit after nothing that draws, so the splash comes
    # down seconds before greetd puts a greeter on the panel and the bare console
    # shows through. Reversing the two, and leaving the last frame on the
    # framebuffer, gives cosmic-comp something to cut from. Every host importing
    # this module runs greetd, via desktop-cosmic.nix.
    #
    # greeterManagesPlymouth is the greetd module's own switch for dropping its
    # After=plymouth-quit-wait; overriding systemd.services.greetd.after cannot
    # do it, since that ordering comes from the module's unitConfig and would
    # only be appended to.
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
