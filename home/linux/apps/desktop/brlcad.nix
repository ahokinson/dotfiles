# pkgs.brlcad installs archer/mged but ships no .desktop entry or app icon,
# unlike every other GUI package here - its own packaging assets
# (misc/debian/archer.desktop, misc/debian/icons/*/brlcad.png upstream)
# aren't wired into the nixpkgs derivation, so both are synthesized here.
{
  pkgs,
  lib,
  selfPath,
  ...
}:
let
  palette = import (selfPath "home/common/theme/palette.nix");

  # Archer's own preferences file: plain "set mFoo bar" lines it reads with
  # a bare `eval` per line (src/tclscripts/archer/Archer.tcl's
  # readPreferences), so any key left out here just keeps Archer's builtin
  # default instead of erroring. Covers the 3D view's informational overlays
  # only - mViewAxesColor/mModelAxesColor deliberately untouched, since the
  # X/Y/Z gizmo's red/green/blue is a spatial convention, not decoration.
  # Archer rewrites this file wholesale on its own "Save preferences", so a
  # value changed from inside the app will be overwritten back to this on
  # the next home-manager switch - same as every other Nix-managed dotfile
  # here.
  #
  # mBackgroundColor/mFBBackgroundColor used to be stuck on the nine named
  # colors cadwidgets::Ged::get_rgb_color recognized (Grey/Black/Navy/Blue/
  # Cyan/Green/Magenta/Red/Yellow/White, silently white for anything else,
  # hex included) - patched below (brlcadThemed's Ged.tcl substitution) to
  # fall back to real Tk color resolution instead of giving up, so hex works
  # here same as every other field.
  archerrc = ''
    set mBackgroundColor "${palette.base}"
    set mFBBackgroundColor "${palette.base}"
    set mGridColor "${palette.surface1}"
    set mGroundPlaneMajorColor "${palette.overlay0}"
    set mGroundPlaneMinorColor "${palette.surface1}"
    set mPrimitiveLabelColor "${palette.yellow}"
    set mScaleColor "${palette.text}"
    set mViewingParamsColor "${palette.subtext1}"
    set mMeasuringStickColor "${palette.green}"
    set mRayColorOdd "${palette.mauve}"
    set mRayColorEven "${palette.pink}"
    set mRayColorVoid "${palette.crust}"
    set mRtWizardEdgeColor "${palette.lavender}"
    set mRtWizardNonEdgeColor "${palette.surface2}"
  '';

  # Classic Tk widget chrome (menus, buttons, panels, dialogs) - the part
  # .archerrc doesn't reach. Scoped under the "Archer" resource class
  # (confirmed via `xprop WM_CLASS` on a running instance: instance
  # "archer0", class "Archer") rather than a bare "*" wildcard, so this
  # doesn't reskin mged or any other stray Tk app on the same X server.
  # Best-effort only: a handful of Archer's own dialogs (e.g. the
  # preferences panel) set their background in code via a hardcoded Tcl
  # constant, which always wins over the resource database, so those stay
  # gray regardless.
  archerXresources = pkgs.writeText "archer.xresources" ''
    Archer*background: ${palette.base}
    Archer*foreground: ${palette.text}
    Archer*activeBackground: ${palette.surface1}
    Archer*activeForeground: ${palette.text}
    Archer*selectBackground: ${palette.surface2}
    Archer*selectForeground: ${palette.text}
    Archer*selectColor: ${palette.yellow}
    Archer*insertBackground: ${palette.text}
    Archer*troughColor: ${palette.mantle}
    Archer*highlightBackground: ${palette.base}
    Archer*highlightColor: ${palette.surface2}
    Archer*disabledForeground: ${palette.overlay0}
    Archer*Entry.background: ${palette.crust}
    Archer*Text.background: ${palette.crust}
    Archer*Listbox.background: ${palette.crust}
    Archer*Menu.background: ${palette.base}
    Archer*Menu.foreground: ${palette.text}
    Archer*Menu.activeBackground: ${palette.surface1}
    Archer*Menubutton.background: ${palette.base}
    Archer*Button.background: ${palette.surface0}
    Archer*Scrollbar.background: ${palette.surface0}
    Archer*Scrollbar.troughColor: ${palette.mantle}
  '';

  # The real fix for the chrome archerXresources can't reach: ArcherCore.tcl
  # sets its LABEL_BACKGROUND_COLOR class variable once, at class-definition
  # time, to `[::ttk::style lookup label -background]` - and dozens of call
  # sites read it back as a plain color string wherever they build a widget
  # (the primary toolbar, ArcherCore's own top-level background, every
  # secondary dialog). The Tree panel is a real ttk::treeview with no
  # explicit color at all, so it's driven by ttk styles directly. Both
  # trace back to one thing: whatever ttk theme is active when
  # share/tclscripts/archer/init/archer_launch.tcl runs
  # `::ttk::style theme use clam`, right before it loads Archer's classes -
  # so configuring the styles immediately after that line, before
  # `package require Archer` evaluates, recolors all of it at the source
  # instead of fighting each call site.
  #
  # Patched as a copy of the already-built pkgs.brlcad rather than an
  # overlay/overrideAttrs on the derivation itself, since the latter would
  # force a full from-source rebuild (brlcad has no binary cache) just to
  # change one text file. symlinkJoin mirrors the whole closure as symlinks
  # and only archer_launch.tcl needs to become a real file to edit.
  # wrapProgram's BRLCAD_ROOT matters more than it looks: bu_dir() resolves
  # BU_DIR_DATA from the running binary's own realpath by default (through
  # any symlink, straight back to the original pkgs.brlcad store path,
  # which would silently load the unpatched script) - but it checks
  # BRLCAD_ROOT first and returns immediately if set
  # (src/libbu/dir.c's _bu_dir_brlcad_root), so this is what actually makes
  # $out/share/tclscripts/... the one that gets read.
  #
  # Also carries `option add` lines for the classic (non-ttk) menu
  # dropdowns: the File/Display/Modes/etc. cascades are plain Tk `menu`
  # widgets with no color option set anywhere in Archer's code, so ttk
  # styles never reach them and they render with Tk's compiled-in stock
  # white/black look. `option add` populates Tk's own in-process option
  # database directly - unlike the xrdb-merged X resources in
  # archerXresources below, which sit on the X server and this app largely
  # doesn't consult, this is what actually reaches a classic widget that
  # never sets its own color. NB: this whole block is spliced into a
  # single-quoted shell string in brlcadThemed's postBuild, so no
  # apostrophes here even in comments.
  ttkThemeOverrides = ''
    ::ttk::style configure . -background "${palette.base}" -foreground "${palette.text}" -fieldbackground "${palette.crust}"
    ::ttk::style configure TLabel -background "${palette.base}" -foreground "${palette.text}"
    ::ttk::style configure TFrame -background "${palette.base}"
    ::ttk::style configure TButton -background "${palette.surface0}" -foreground "${palette.text}"
    ::ttk::style configure TCheckbutton -background "${palette.base}" -foreground "${palette.text}"
    ::ttk::style configure TRadiobutton -background "${palette.base}" -foreground "${palette.text}"
    ::ttk::style configure TEntry -fieldbackground "${palette.crust}" -foreground "${palette.text}"
    ::ttk::style configure TCombobox -fieldbackground "${palette.crust}" -foreground "${palette.text}"
    ::ttk::style configure TNotebook -background "${palette.base}"
    ::ttk::style configure TNotebook.Tab -background "${palette.surface0}" -foreground "${palette.text}"
    ::ttk::style map TNotebook.Tab -background [list selected "${palette.base}"]
    ::ttk::style configure Treeview -background "${palette.crust}" -fieldbackground "${palette.crust}" -foreground "${palette.text}"
    ::ttk::style configure Treeview.Heading -background "${palette.base}" -foreground "${palette.text}"
    ::ttk::style map Treeview -background [list selected "${palette.surface2}"] -foreground [list selected "${palette.text}"]
    ::ttk::style configure TScrollbar -background "${palette.surface0}" -troughcolor "${palette.mantle}" -arrowcolor "${palette.text}"
    ::ttk::style configure Vertical.TScrollbar -background "${palette.surface0}" -troughcolor "${palette.mantle}" -arrowcolor "${palette.text}"
    ::ttk::style configure Horizontal.TScrollbar -background "${palette.surface0}" -troughcolor "${palette.mantle}" -arrowcolor "${palette.text}"

    option add *Menu.background "${palette.base}" widgetDefault
    option add *Menu.foreground "${palette.text}" widgetDefault
    option add *Menu.activeBackground "${palette.surface1}" widgetDefault
    option add *Menu.activeForeground "${palette.text}" widgetDefault
    option add *Menu.selectColor "${palette.yellow}" widgetDefault
    option add *Menu.disabledForeground "${palette.overlay0}" widgetDefault
  '';

  brlcadThemed = pkgs.symlinkJoin {
    name = "brlcad-themed-${pkgs.brlcad.version}";
    paths = [ pkgs.brlcad ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/share/tclscripts/archer/init/archer_launch.tcl"
      substitute \
        "${pkgs.brlcad}/share/tclscripts/archer/init/archer_launch.tcl" \
        "$out/share/tclscripts/archer/init/archer_launch.tcl" \
        --replace-fail \
          '::ttk::style theme use clam' \
          '::ttk::style theme use clam
      ${ttkThemeOverrides}'

      # ArcherCore.tcl builds the Command-tab text widget with
      # -textbackground $SystemWindow (already dark via the ttk fix above),
      # then immediately force-overrides it right back to literal "white" -
      # an explicit `configure` call always wins over both ttk styles and
      # the X resource database, so this is the one spot neither of those
      # mechanisms could ever reach. -result_color black is the same
      # problem one option over: it colors a command's output text, and
      # black-on-black is invisible once the background is actually dark.
      rm "$out/share/tclscripts/archer/ArcherCore.tcl"
      substitute \
        "${pkgs.brlcad}/share/tclscripts/archer/ArcherCore.tcl" \
        "$out/share/tclscripts/archer/ArcherCore.tcl" \
        --replace-fail \
          '-result_color black' \
          '-result_color "${palette.text}"' \
        --replace-fail \
          '$itk_component(cmd) component text configure -background white' \
          '$itk_component(cmd) component text configure -background "${palette.crust}" -foreground "${palette.text}" -insertbackground "${palette.text}"'

      # Same "reset to white" pattern in the attribute-groups panel's two
      # list widgets (highlight/select state restores literal white instead
      # of whatever the list's real background is).
      rm "$out/share/tclscripts/archer/AttrGroupsDisplayUtility.tcl"
      substitute \
        "${pkgs.brlcad}/share/tclscripts/archer/AttrGroupsDisplayUtility.tcl" \
        "$out/share/tclscripts/archer/AttrGroupsDisplayUtility.tcl" \
        --replace-fail \
          '$itk_component(alist) itemconfigure $i -background white' \
          '$itk_component(alist) itemconfigure $i -background "${palette.crust}"' \
        --replace-fail \
          '$itk_component(glist) itemconfigure $i -background white' \
          '$itk_component(glist) itemconfigure $i -background "${palette.crust}"'

      # cadwidgets::Ged::get_rgb_color (used for mBackgroundColor/
      # mFBBackgroundColor, and separately for the axes colors this repo
      # deliberately leaves alone) is a closed switch over nine named
      # colors; anything else - hex included - falls through to its
      # default case and comes back as flat white. Rather than add a tenth
      # hardcoded name, make the default case actually resolve the color
      # via winfo rgb (same mechanism ArcherCore::getRgbColor already uses
      # elsewhere) before giving up.
      rm "$out/share/tclscripts/lib/Ged.tcl"
      substitute \
        "${pkgs.brlcad}/share/tclscripts/lib/Ged.tcl" \
        "$out/share/tclscripts/lib/Ged.tcl" \
        --replace-fail \
          'return "255 255 255"' \
          'if {[catch {winfo rgb . $_color} rgb]} {
      return "255 255 255"
      }
      return [list [expr {[lindex $rgb 0] / 256}] [expr {[lindex $rgb 1] / 256}] [expr {[lindex $rgb 2] / 256}]]'

      wrapProgram "$out/bin/archer" --set BRLCAD_ROOT "$out"
    '';
  };
in
{
  # BRL-CAD's own bin/tree (a geometry-tree CLI tool) collides with pkgs.tree
  # (home/common/packages/catalog/system/filesystem.nix, the directory
  # lister everyone actually means by `tree`); lowPrio makes buildEnv keep
  # the latter and drop BRL-CAD's on conflict, rather than failing the
  # whole profile build. Every other BRL-CAD binary is unaffected.
  home.packages = [ (lib.lowPrio brlcadThemed) ];

  home.file.".archerrc".text = archerrc;

  xdg.desktopEntries.archer = {
    name = "Archer";
    comment = "Constructive solid geometry (CSG) solid modeling CAD system";
    exec = "archer";
    icon = "brlcad";
    categories = [
      "Graphics"
      "Science"
      "Engineering"
    ];
  };

  # Archer's OpenGL display manager (ogl_configureWin_guts) draws canvas text
  # with old X11 core bitmap fonts (9x15, Adobe Courier), which XWayland
  # never gets a path to here: neither cosmic nor sway go through
  # services.xserver (the thing that normally wires font-misc-misc/
  # font-adobe-75dpi into Xorg's FontPath), so XWayland starts with only
  # "built-ins". Missing fonts make the canvas configure call throw on every
  # resize, leaving Archer's 3D view permanently blank. xset registers a
  # path at runtime; graphical-session.target is generic enough to fire
  # under either session.
  systemd.user.services.brlcad-x11-fonts = {
    Unit = {
      Description = "Register legacy X11 core fonts for BRL-CAD's OpenGL display manager";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.xset}/bin/xset +fp ${pkgs.font-misc-misc}/share/fonts/X11/misc"
        "${pkgs.xset}/bin/xset +fp ${pkgs.font-adobe-75dpi}/share/fonts/X11/75dpi"
        "${pkgs.xset}/bin/xset fp rehash"
      ];
    };
  };

  # Chrome half of the Catppuccin theme (archerXresources above); merged
  # into the X server's RESOURCE_MANAGER property the same way the font
  # path gets registered, since Tk apps read the resource database once at
  # widget-creation time, not from any file Archer itself would notice.
  systemd.user.services.brlcad-x11-theme = {
    Unit = {
      Description = "Merge Catppuccin X resources for Archer's Tk chrome";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xrdb}/bin/xrdb -merge ${archerXresources}";
    };
  };
}
